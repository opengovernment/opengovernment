module OpenGov::Load::Contributions
  def self.import!
    Person.with_nimsp_candidate_id.each do |person|
      puts "Importing contributions for #{person.full_name}"

      begin
        contributions = GovKit::FollowTheMoney::Contribution.find(person.nimsp_candidate_id)
        contributions ||= []

        puts "Fetched #{contributions.size} contributions from FollowTheMoney"

        puts "Deleting existing contributions.."

        person.contributions.delete_all

        puts "Importing contributions..\n\n"

        contributions.each do |contribution|
          person.contributions << make_contribution(contribution)
        end
        person.save
      rescue Exception => e
        puts "Skipping: #{e.message}"
      end
    end
  end

  def self.make_contribution(con)
    begin
      contribution = Contribution.new
      contribution.business_name = con.business_name
      contribution.contributor_state = con.contributor_state
      contribution.industry_name = con.industry_name
      contribution.contributor_occupation = con.contributor_occupation
      contribution.contributor_employer = con.contributor_employer
      contribution.amount = con.amount
      contribution.date = con.date
      contribution.sector_name = con.sector_name
      contribution.nimsp_industry_code = con.imsp_industry_code
      contribution.nimsp_sector_code = con.imsp_sector_code
      contribution.contributor_city = con.contributor_city
      contribution.contributor_name = con.contributor_name
      contribution.contributor_zipcode = con.contributor_zipcode
      contribution
    rescue
      "Problem saving #{con.business_name}..skipping"
    end
  end
end
