module OpenGov
  class People < Resources
    LEG_DIR = File.join(OPENSTATES_DIR, "api", "legislators")

    class << self
      def import!(options = {})
        State.loadable.each do |state|
          import_one(state, options)
        end
      end

      def import_one(state, options = {})
        if options[:remote]
          # Counters
          i = 0

          GovKit::OpenStates::Legislator.search(:state => state.abbrev).each do |fs_person|
            i = i + 1
            import_person(fs_person, state)
          end

          puts "OpenStates: Imported #{i} people from remote data"
        else
          unless File.exists?(LEG_DIR)
            puts "Local Open States data not found in #{LEG_DIR}; fetching remotely instead."
            return import_one(state, :remote => true)
          end

          state_legs = File.join(LEG_DIR, "#{state.abbrev}*")
          i = 0

          Dir.glob(state_legs).each do |file|
            i = i + 1
            leg = GovKit::OpenStates::Legislator.parse(JSON.parse(File.read(file)))
            import_person(leg, state)
          end

          puts "OpenStates: Imported #{i} people in #{state.abbrev} from local data"
        end
      end

      def import_person(fs_person, state)
        Person.transaction do
          unless person = Person.find_by_openstates_id(fs_person.leg_id)
            person = Person.new(:openstates_id => fs_person.leg_id)
          end

          person.update_attributes!(
            :first_name => fs_person.first_name,
            :last_name => fs_person.last_name,
            :votesmart_id => fs_person[:votesmart_id],
            :nimsp_candidate_id => fs_person[:nimsp_candidate_id],
            :middle_name => fs_person.middle_name,
            :suffix => fs_person[:suffixes],
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

              if district = chamber.districts.numbered(fs_role.district.to_s).first
                role = Role.find_or_initialize_by_person_id_and_session_id(person.id, session.id)
                role.update_attributes!(
                  :district_id => district.id,
                  :chamber_id => chamber.id,
                  :start_date => Date.valid_date!(fs_role.start_date),
                  :end_date => Date.valid_date!(fs_role.end_date),
                  :party => standardize_party(fs_role.party)
                )
              else
                puts "Could not find district #{fs_role.district.to_s} served by #{person.full_name} (#{person.openstates_id}) in #{state.abbrev}; skipping"
              end
            # Ignore committee memberships; we're getting those from committees/ data.
            #when GovKit::OpenStates::ROLE_COMMITTEE_MEMBER
              # Their votesmart_committee_id may be nil
            end
          end
        end # transaction
      end # import_one

      private
      
      def standardize_party(party_name)
        case party_name.downcase
        when 'democrat', 'd', 'democratic', 'dem'
          'Democratic'
        when 'republican', 'r', 'rep'
          'Republican'
        else
          'Independent'
        end
      end
    end # standardize_party

  end
end
