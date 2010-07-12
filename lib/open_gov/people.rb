module OpenGov
  class People < Resources
    class << self
      def import!(options = {})
        if options[:remote]
          State.loadable.each do |state|
            import_state(state)
          end
        else
          leg_dir = File.join(FIFTYSTATES_DIR, "api", "legislators")

          unless File.exists?(leg_dir)
            puts "Local Fifty States data is missing; fetching remotely instead."
            return import!(:remote => true)
          end

          State.loadable.each do |state|
            state_legs = File.join(leg_dir, "#{state.abbrev}*")
            i = 0

            Dir.glob(state_legs).each do |file|
              i = i + 1
              leg = GovKit::FiftyStates::Legislator.parse(JSON.parse(File.read(file)))
              import_one(leg, state)
            end

            puts "FiftyStates: Imported #{i} people from local data"
          end
          
        end
      end

      def import_state(state)
        # Counters
        i = 0

        GovKit::FiftyStates::Legislator.search(:state => state.abbrev).each do |fs_person|
          i = i + 1
          import_one(fs_person, state)
        end

        puts "FiftyStates: Imported #{i} people from remote data"
      end

      def import_one(fs_person, state)
        Person.transaction do
        
          unless person = Person.find_by_fiftystates_id(fs_person.leg_id)
            person = Person.new(:fiftystates_id => fs_person.leg_id)
          end

          person.update_attributes!(
            :first_name => fs_person.first_name,
            :last_name => fs_person.last_name,
            :votesmart_id => fs_person.votesmart_id,
            :nimsp_candidate_id => fs_person.nimsp_candidate_id,
            :middle_name => fs_person.middle_name,
            :suffix => fs_person.suffixes,
            :updated_at => valid_date!(fs_person.updated_at),
            :fiftystates_photo_url => fs_person.photo_url
          )

          person.save!

          fs_person.roles.each do |fs_role|
            legislature = state.legislature
            session = Session.find_by_legislature_id_and_name(state.legislature, fs_role.session)

            case fs_role[:type]
            when GovKit::FiftyStates::ROLE_MEMBER :

              chamber =
                case fs_role.chamber
                when GovKit::FiftyStates::CHAMBER_UPPER
                  legislature.upper_chamber
                when GovKit::FiftyStates::CHAMBER_LOWER
                  legislature.lower_chamber
                end
<<<<<<< HEAD
=======

              district = chamber.districts.numbered(fs_role.district.to_s).first

              role = Role.find_or_initialize_by_district_id_and_chamber_id(district.id, chamber.id)
              role.update_attributes!(
                :person => person,
                :session => session,
                :start_date => valid_date!(fs_role.start_date),
                :end_date => valid_date!(fs_role.end_date),
                :party => fs_role.party
              )
            when GovKit::FiftyStates::ROLE_COMMITTEE_MEMBER :
              # Their votesmart_committee_id may be nil
              if committee = (fs_role.votesmart_committee_id? ? Committee.find_by_votesmart_id(fs_role.votesmart_committee_id) : Committee.find_or_create_by_name_and_legislature_id(fs_role.committee, legislature.id))
                committee_membership = CommitteeMembership.find_or_create_by_person_id_and_session_id_and_committee_id(person.id, session.id, committee.id)
              end
>>>>>>> 6bca72b858c3acd505fa2bf1b9f82f2ba0bffd03
            end
          end
        end # transaction
      end # import_one
    end
  end
end
