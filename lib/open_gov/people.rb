module OpenGov
  class People < Resources
    LEG_DIR = File.join(Settings.openstates_dir, "api", "legislators")

    def self.import!(options = {})
      State.loadable.each do |state|
        import_state(state, options)
      end
    end

    def self.import_state(state, options = {})
      if options[:remote]
        # Counters
        i = 0

        GovKit::OpenStates::Legislator.search(:state => state.abbrev).each do |fs_person|
          i = i + 1
          import_person(fetch_person(fs_person.leg_id), state)
        end

        puts "OpenStates: Imported #{i} people in #{state.abbrev} from remote data"
      else
        unless File.exists?(LEG_DIR)
          puts "Local Open States data not found in #{LEG_DIR}; fetching remotely instead."
          return import_state(state, :remote => true)
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
    
    private

    def self.fetch_person(leg_id)
#      puts "Fetching #{leg_id}"
      GovKit::OpenStates::Legislator.find(leg_id)
    end

    def self.import_person(fs_person, state)
      Person.transaction do
        unless person = Person.find_by_openstates_id(fs_person.leg_id)
          person = Person.new(:openstates_id => fs_person.leg_id)
        end

#        puts fs_person.leg_id

        person.attributes = {
          :first_name => fs_person.first_name,
          :last_name => fs_person.last_name,
          :votesmart_id => fs_person[:votesmart_id],
          :nimsp_candidate_id => fs_person[:nimsp_candidate_id],
          :transparencydata_id => fs_person[:transparencydata_id],
          :middle_name => fs_person.middle_name,
          :suffix => fs_person[:suffixes],
          :updated_at => Date.valid_date!(fs_person.updated_at),
          :photo_url => fs_person.photo_url? ? fs_person.photo_url : nil
        }

        person.save! if person.changed?

        unless fs_person[:sources].blank?
          person.citations.destroy_all

          fs_person.sources.each do |source|
            person.citations << Citation.new(
              :url => source.url,
              :retrieved => Date.valid_date!(source.retrieved)
            )
          end
        end

        # We'll look at all roles, just in case we're importing from scratch
        
        # Unfortunately old_roles is a hash and roles is an array.
        # This may need to change if/when old_roles becomes an array.
        if fs_person[:old_roles]
          all_roles = fs_person[:old_roles].attributes.values | fs_person[:roles]
        else
          all_roles = fs_person[:roles]
        end

        all_roles.flatten.each do |fs_role|
          legislature = state.legislature
          session = Session.find_by_legislature_id_and_name(state.legislature, fs_role.term)

#          puts "- role #{fs_role[:type]} in term #{fs_role.term}"
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
              role.attributes = {
                :district_id => district.id,
                :chamber_id => chamber.id,
                :start_date => Date.valid_date!(fs_role.start_date),
                :end_date => Date.valid_date!(fs_role.end_date),
                :party => standardize_party(fs_role.party)
              }
              role.save! if role.changed?
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
    
    def self.standardize_party(party_name)
      case party_name.downcase
      when 'democrat', 'd', 'democratic', 'dem'
        'Democrat'
      when 'republican', 'r', 'rep'
        'Republican'
      else
        'Independent'
      end
    end # standardize_party

  end
end
