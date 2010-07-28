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
          end

          contributions ||= []

          puts "Fetched #{contributions.size} contributions from FollowTheMoney"

          puts "Importing contributions..\n\n"

          contributions.each do |contribution|
            person.contributions << make_contribution(contribution)
          end
          person.save!
        end
      end

      def make_contribution(con)
        business = Business.find_by_nimsp_sector_code_and_nimsp_industry_code(con.imsp_sector_code, con.imsp_industry_code)
        contribution = business.contributions.build(
          :contributor_state_id => State.find_by_abbrev(con.contributor_state),
          :contributor_occupation => con.contributor_occupation,
          :contributor_employer => con.contributor_employer,
          :amount => con.amount,
          :date => Date.valid_date!(con.date),
          :contributor_city => con.contributor_city,
          :contributor_name => con.contributor_name,
          :contributor_zipcode => con.contributor_zipcode
        )
        contribution
      end
    end
  end
end
