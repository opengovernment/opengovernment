module OpenGov
  class People < Resources
    class << self
      def import!(options = {})
        if options[:remote]
          State.loadable.each do |state|
            import_state(state)
          end
        else
          leg_dir = File.join(OPENSTATES_DIR, "api", "legislators")

          unless File.exists?(leg_dir)
            puts "Local Open States data is missing; fetching remotely instead."
            return import!(:remote => true)
          end

          State.loadable.each do |state|
            state_legs = File.join(leg_dir, "#{state.abbrev}*")
            i = 0

            Dir.glob(state_legs).each do |file|
              i = i + 1
              leg = GovKit::OpenStates::Legislator.parse(JSON.parse(File.read(file)))
              import_one(leg, state)
            end

            puts "OpenStates: Imported #{i} people from local data"
          end

        end
      end

      def import_state(state)
        # Counters
        i = 0

        GovKit::OpenStates::Legislator.search(:state => state.abbrev).each do |fs_person|
          i = i + 1
          import_one(fs_person, state)
        end

        puts "OpenStates: Imported #{i} people from remote data"
      end

      def import_one(fs_person, state)
        Person.transaction do

          unless person = Person.find_by_openstates_id(fs_person.leg_id)
            person = Person.new(:openstates_id => fs_person.leg_id)
          end

          person.update_attributes!(
            :first_name => fs_person.first_name,
            :last_name => fs_person.last_name,
            :votesmart_id => fs_person.votesmart_id,
            :nimsp_candidate_id => fs_person.nimsp_candidate_id,
            :middle_name => fs_person.middle_name,
            :suffix => fs_person.suffixes,
            :updated_at => Date.valid_date!(fs_person.updated_at),
            :openstates_photo_url => fs_person.photo_url? ? fs_person.photo_url : nil
          )

          person.save!

          fs_person.roles.each do |fs_role|
            legislature = state.legislature
            session = Session.find_by_legislature_id_and_name(state.legislature, fs_role.term)

            case fs_role[:type]
            when GovKit::OpenStates::ROLE_MEMBER

              chamber =
                case fs_role.chamber
                when GovKit::OpenStates::CHAMBER_UPPER
                  legislature.upper_chamber
                when GovKit::OpenStates::CHAMBER_LOWER
                  legislature.lower_chamber
                end

              district = chamber.districts.numbered(fs_role.district.to_s).first

              role = Role.find_or_initialize_by_person_id_and_session_id(person.id, session.id)
              role.update_attributes!(
                :district_id => district.id,
                :chamber_id => chamber.id,
                :start_date => Date.valid_date!(fs_role.start_date),
                :end_date => Date.valid_date!(fs_role.end_date),
                :party => fs_role.party
              )
            when GovKit::OpenStates::ROLE_COMMITTEE_MEMBER
              # Their votesmart_committee_id may be nil
              if committee = (fs_role.votesmart_committee_id? ? Committee.find_by_votesmart_id(fs_role.votesmart_committee_id) : Committee.find_or_create_by_name_and_legislature_id(fs_role.committee, legislature.id))
                committee_membership = CommitteeMembership.find_or_create_by_person_id_and_session_id_and_committee_id(person.id, session.id, committee.id)
              end
            end
          end
        end # transaction
      end # import_one
    end
  end
end
