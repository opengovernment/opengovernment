module OpenGov
  class Contributions < Resources
    class << self
      def import!
        puts "Deleting existing contributions.."

        Contribution.delete_all

        Person.with_nimsp_candidate_id.each do |person|
          puts "Importing contributions for #{person.full_name}"

          begin
            contributions = GovKit::FollowTheMoney::Contribution.find(person.nimsp_candidate_id)
          rescue Crack::ParseError => e
            puts e.class.to_s + ": Invalid JSON for person " + person.nimsp_candidate_id.to_s
          rescue GovKit::ResourceNotFound => e
            puts "Skipping #{person.full_name}--No contributions found."
          end

          contributions ||= []

          puts "Fetched #{contributions.size} contributions from FollowTheMoney"

          puts "Importing contributions..\n\n"

          Contribution.transaction do
            contributions.each do |contribution|
              make_contribution(person, contribution)
            end
          end
        end
      end

      def make_contribution(person, con)
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
end
