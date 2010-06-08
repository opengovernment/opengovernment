module OpenGov::Load::Contributions
  def self.import!
    Person.with_nimsp_candidate_id.each do |person|
      puts "Importing contributions for #{person.full_name}"

      begin
        contributions = GovKit::FollowTheMoney::Contribution.find(person.nimsp_candidate_id)
      rescue Crack::ParseError => e
        puts e.class.to_s + ": Invalid JSON for person " + person.nimsp_candidate_id.to_s
      end

      contributions ||= []

      puts "Fetched #{contributions.size} contributions from FollowTheMoney"

      puts "Deleting existing contributions.."

      person.contributions.delete_all

      puts "Importing contributions..\n\n"

      contributions.each do |contribution|
        person.contributions << make_contribution(contribution)
      end
      person.save!

    end
  end

  def self.make_contribution(con)
    business = Business.find_by_nimsp_sector_code_and_nimsp_industry_code(con.imsp_sector_code, con.imsp_industry_code)

    begin
      raise ActiveRecord::RecordNotFound, "Associate business not found" unless business
      contribution = business.contributions.build(
        :contributor_state_id => State.find_by_abbrev(con.contributor_state),
        :contributor_occupation => con.contributor_occupation,
        :contributor_employer => con.contributor_employer,
        :amount => con.amount,
        :date => con.date,
        :contributor_city => con.contributor_city,
        :contributor_name => con.contributor_name,
        :contributor_zipcode => con.contributor_zipcode
      )
      contribution
    rescue ActiveRecord::RecordNotFound => e
      puts "Skipping: " + e.inspect
    end
  end
end
