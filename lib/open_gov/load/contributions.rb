module OpenGov::Load::Contributions
  def self.import!
    Person.with_nimsp_candidate_id.each do |person|
      puts "Importing contributions for #{person.full_name}"

      begin
        contributions = GovKit::FollowTheMoney::Contribution.find(person.nimsp_candidate_id)
        contributions ||= []

        puts "Fetched #{contributions.size} businesses from FollowTheMoney"

        puts "Deleting existing contributions.."

        person.contributions.delete_all

        puts "Importing contributions..\n\n"

        contributions.each do |contribution|
          import_contribution(contribution)
        end
      rescue
        puts "Problem parsing ..skipping"
      end
    end
  end

  def self.import_contribution(contribution)
    begin
#    business = Business.new
#    business.business_name = bus.business_name
#    business.industry_name = bus.industry_name
#    business.sector_name = bus.sector_name
#    business.nimsp_industry_code = bus.imsp_industry_code
#    business.nimsp_sector_code = bus.imsp_sector_code
#    business.save!
    rescue
      "Problem saving #{contribution.business_name}..skipping"
    end
  end
end
