module OpenGov
  class Contributions < Resources
    include StateWise

    # This value for transaction_namespace= in TD API cals limits our queries with TransparencyData to the NIMSP dataset.
    IMSP_NAMESPACE = 'urn:nimsp:recipient'

    def import_state(state, options = {})      
      options[:immediate] ||= false

      puts "Adding contribution import tasks to delayed_job queue" unless options[:immediate]

      Person.find_by_sql(['SELECT distinct people.id FROM "roles" INNER JOIN "people" ON "people"."id" = "roles"."person_id" WHERE (roles.district_id in (select id from districts where state_id = ?) or roles.state_id = ?) AND (people.transparencydata_id is not null)', state.id, state.id]).each do |person|

        # Import each person's contributions asynchronously.
        if options[:immediate] == true
          import_person(person.id)
        else
          self.delay.import_person(person.id)
        end
      end
    end

    def import!
      import(:immediate => true)
    end

    def import_state!(state, options = {})
      import_state(state, options.merge(:immediate => true))
    end

    def import_person(person_id)
      cache_states

      if person = Person.find(person_id, :conditions => 'transparencydata_id is not null')
        puts "Deleting contributions for #{person.full_name}"
        Contribution.delete_all(:person_id => person.id)        

        puts "Importing contributions for #{person.full_name}"
        total = 0

        begin
          entity = GovKit::TransparencyData::Entity.find(person.transparencydata_id)
          entity.external_ids.each do |eid|
            page = 0
            td_contributions = []

            # Fetch the NIMSP external ids only.
            # puts "fetching '#{eid[:namespace]}' '#{eid[:id]}'"
            if eid[:namespace].eql?(IMSP_NAMESPACE)
              # Loop to get all contributions
              begin
                page += 1
                begin
                  td_contributions = GovKit::TransparencyData::Contribution.search(:recipient_ext_id => eid[:id], :recipient_type => 'P', :page => page)

                  contributions_to_import = []

                  td_contributions.each do |contribution|
                    contributions_to_import << make_contribution(person, contribution)
                  end

                  begin
                    puts "attempting to insert #{contributions_to_import.size} contributions"
                    result = Contribution.import contributions_to_import

                    if !result.failed_instances.empty?
                      puts "The following rows had errors and were not inserted: #{result.failed_instances.inspect}"
                    end
                  end
                  # process them.
                rescue Crack::ParseError => e
                  puts e.class.to_s + ": Invalid JSON for person " + person.transparencydata_id
                  break
                rescue GovKit::ResourceNotFound => e
                  puts "Got resource not found."
                  break
                end
                total += td_contributions.size
              end while td_contributions.size >= 1000
            end
          end
        rescue GovKit::ResourceNotFound => e
          puts "Resource not found on entity lookup: #{person.transparencydata_id}"
        end

        puts "Fetched #{total} contributions from TransparencyData"
      end
    end

    private

    def make_contribution(person, con)
      Contribution.new(
        :person_id => person.id,
        :state_id => person.state_id,
        :industry_id => con.contributor_category,
        :contributor_state_id => @states[con.contributor_state.upcase],
        :contributor_occupation => con.contributor_occupation,
        :contributor_employer => con.contributor_employer,
        :amount => con.amount,
        :date => Date.valid_date!(con.date),
        :contributor_city => con.contributor_city,
        :contributor_name => con.contributor_name,
        :contributor_zipcode => con.contributor_zipcode,
        :transparencydata_id => con.transaction_id
      )
    end
  
    def cache_states
      # Cache all of the ids of people so we don't have to keep looking them up.
      @states ||= {}

      if @states.size == 0
        State.all.each do |s|
          @states[s.abbrev.upcase] = s.id
        end
      end
    end

  end
end
