module OpenGov
  class Committees < Resources  
    COMMITTEE_DIR = File.join(Settings.openstates_dir, "committees")

    def import(options = {})
      State.loadable.each do |state|
        import_state(state, options)
      end
    end

    def import_state(state, options = {})
      unless options[:remote] || File.exists?(COMMITTEE_DIR)
        puts "Local Open States committee data not found in #{COMMITTEE_DIR}; fetching remotely instead."
        return import_state(state, :remote => true)
      end

      if options[:remote]
        # Counters
        i = 0

        puts "---------- Loading #{state.name} committee data from remote OpenStates data."
        GovKit::OpenStates::Committee.search(:state => state.abbrev).each do |search_result|
#          puts "fetching committee #{search_result[:id]}..."
          if committee = GovKit::OpenStates::Committee.find(search_result[:id])
            i = i + 1
            import_openstates_committee(committee, state)
          else
            puts "Could not find committee #{search_result.id} at OpenStates"
          end
        end

        puts "OpenStates: Imported #{i} committees in #{state.abbrev} from remote data"
      else
        # Import from local data
        puts "---------- Loading #{state.name} committee data from local OpenStates data."
        state_committees = File.join(COMMITTEE_DIR, "#{state.abbrev}*")
        i = 0

        Dir.glob(state_committees).each do |file|
          i = i + 1
          import_openstates_committee(GovKit::OpenStates::Committee.parse(JSON.parse(File.read(file))), state)
        end

        puts "OpenStates: Imported #{i} committees in #{state.abbrev} from local data"
      end
    
    end

    def import_openstates_committee(os_com, state)
        legislature_id = state.legislature.id
        subclass = Committee.subclass_from_openstates_chamber(os_com.chamber)

        Committee.transaction do

          if committee = subclass.find_or_initialize_by_legislature_id_and_name(legislature_id, os_com[:subcommittee] || os_com[:committee])

            committee.openstates_id = os_com[:id]
            if os_com[:parent_id]
              committee.parent = subclass.find_by_openstates_id(os_com[:parent_id])
            end
            committee.save

            # Delete all memberships for now, since we can't associate them with specific sessions.
            committee.committee_memberships.destroy_all

            os_com.members.each do |os_role|
              if os_role[:leg_id] && person = Person.find_by_openstates_id(os_role[:leg_id])
                committee_membership = CommitteeMembership.find_or_initialize_by_person_id_and_committee_id(person.id, committee.id)
                # TODO: Associate committee memberships with a specific session.
                committee_membership.full_name = os_role[:name]
                committee_membership.role = os_role[:role]
                committee_membership.save
              else
                # A committee membership without a leg_id.
                if os_role[:name]
                  committee_membership = CommitteeMembership.find_or_create_by_role_and_full_name_and_committee_id(os_role[:role], os_role[:name], committee.id)
                end                  
              end
            end
          end

        end # transaction
    end

  end
end
