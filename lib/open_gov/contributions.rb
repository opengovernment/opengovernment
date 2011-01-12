module OpenGov
  class Contributions < Resources
    def self.import!
      puts "Deleting existing contributions.."

      Contribution.delete_all

      Person.with_transparencydata_id.each do |person|
        puts "Importing contributions for #{person.full_name}"

        begin
          entity = GovKit::TransparencyData::Entity.find_by_id(person.transparencydata_id)
          entity.external_ids.each do |eid|
            # Fetch the NIMSP external ids only.
            page = 0
            if eid[:namespace] == 'urn:nimsp:recipient'
              page += 1
              begin
                contributions = GovKit::TransparencyData::Contribution.find(:transaction_namespace => 'urn:nimsp:transaction', :recipient_ext_id => eid[:id])

                rescue Crack::ParseError => e
                  puts e.class.to_s + ": Invalid JSON for person " + person.transparencydata_id
                  contributions = []
                  break
                rescue GovKit::ResourceNotFound => e
                  contributions = []
                  break
                end

              end while contributions.size > 0
            end
          end

        contributions ||= []

        puts "Fetched #{contributions.size} contributions from TransparencyData"

        puts "Importing contributions..\n\n"

        Contribution.transaction do
          contributions.each do |contribution|
            make_contribution(person, contribution)
          end
        end
      end
    end

    def self.make_contribution(person, con)
      business = Business.find_by_name(con.business_name)
      contribution = business.contributions.create(
        :person_id => person.id,
        :state_id => person.state_id,
        :contributor_state_id => con.contributor_state.blank? ? nil : State.find_by_abbrev(con.contributor_state).try(:id),
        :contributor_occupation => con.contributor_occupation,
        :contributor_employer => con.contributor_employer,
        :amount => con.amount,
        :date => Date.valid_date!(con.date),
        :contributor_city => con.contributor_city,
        :contributor_name => con.contributor_name,
        :contributor_zipcode => con.contributor_zipcode
      )
    end
  end
end
