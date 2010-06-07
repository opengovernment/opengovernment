module OpenGov::Load::Businesses
  def self.import!
    businesses = GovKit::FollowTheMoney::Business.list

    puts "Fetched #{businesses.size} businesses from FollowTheMoney"

    puts "Deleting existing buisinesses.."
    Business.delete_all

    businesses.each do |business|
      begin
        import_business(business)
      rescue
        "Problem saving #{business.business_name}..skipping"
      end
    end
  end

  def self.import_business(bus)
    puts "Importing: #{bus.business_name}"

    business = Business.new
    business.business_name = bus.business_name
    business.industry_name = bus.industry_name
    business.sector_name = bus.sector_name
    business.nimsp_industry_code = bus.imsp_industry_code
    business.nimsp_sector_code = bus.imsp_sector_code
    business.save!
  end
end
