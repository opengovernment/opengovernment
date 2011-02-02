module OpenGov
  class Contributions < Resources

    @@states = {}

    def self.build_state_hash
      # Cache all of the ids of people so we don't have to keep looking them up.
      if @@states.size == 0
        State.all.each do |s|
          @@states[s.abbrev.upcase] = s.id
        end
      end
    end
    
    # This value for transaction_namespace= in TD API cals limits our queries with TransparencyData to the NIMSP dataset.
    IMSP_NAMESPACE = 'urn:nimsp:recipient'
    
    def self.import!(options = {})
      State.loadable.each do |state|
        import_state(state, options)
      end
    end

    def self.import_state(state, options = {})
      build_state_hash
      
      Person.find_by_sql(['SELECT distinct people.* FROM "roles" INNER JOIN "people" ON "people"."id" = "roles"."person_id" WHERE (roles.district_id in (select id from districts where state_id = ?) or roles.state_id = ?) AND (people.transparencydata_id is not null)', state.id, state.id]).each do |person|
        puts "Deleting contributions for #{person.full_name}"
        Contribution.delete_all(:person_id => person.id)        
        
        puts "Importing contributions for #{person.full_name}"
        total = 0

        begin
          entity = GovKit::TransparencyData::Entity.find_by_id(person.transparencydata_id)
          entity.external_ids.each do |eid|
            page = 0
            contributions = []

            # Fetch the NIMSP external ids only.
            # puts "fetching '#{eid[:namespace]}' '#{eid[:id]}'"
            if eid[:namespace].eql?(IMSP_NAMESPACE)
              # Loop to get all contributions
              begin
                page += 1
                begin
                  contributions = GovKit::TransparencyData::Contribution.find(:recipient_ext_id => eid[:id], :recipient_type => 'P', :page => page)
                
                  contributions.each do |contribution|
                    make_contribution(person, contribution)
                  end
                  # process them.
                rescue Crack::ParseError => e
                  puts e.class.to_s + ": Invalid JSON for person " + person.transparencydata_id
                  break
                rescue GovKit::ResourceNotFound => e
                  puts "Got resource not found."
                  break
                end
                total += contributions.size
              end while contributions.size >= 1000
            end
          end
        rescue GovKit::ResourceNotFound => e
          puts "Resource not found on entity lookup: #{person.transparencydata_id}"
        end

        puts "Fetched #{total} contributions from TransparencyData"
      end
    end

    private

    def self.make_contribution(person, con)
      begin
        contribution = Contribution.create(
          :person_id => person.id,
          :state_id => person.state_id,
          :industry_id => con.contributor_category,
          :contributor_state_id => @@states[con.contributor_state.upcase],
          :contributor_occupation => con.contributor_occupation,
          :contributor_employer => con.contributor_employer,
          :amount => con.amount,
          :date => Date.valid_date!(con.date),
          :contributor_city => con.contributor_city,
          :contributor_name => con.contributor_name,
          :contributor_zipcode => con.contributor_zipcode,
          :transparencydata_id => con.transaction_id
        )
      rescue ActiveRecord::InvalidForeignKey => e
        puts "Could not find contributor category with code #{con.contributor_category} on transaction #{con.transaction_id}; skipping."
      end
    end
  end
end
