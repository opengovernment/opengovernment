module OpenGov
  class Businesses < Resources
    # TODO: This should be more cleanly separated from contributions --
    # so we don't have to delete all contributions when we load businesses (the second time)
    
    class << self
      def fetch
        businesses = GovKit::FollowTheMoney::Business.list
        puts "Fetched #{businesses.size} businesses from FollowTheMoney"
        businesses
      end

      def import!
        businesses = fetch
        puts "Deleting existing buisinesses and contributions.."        
        Contribution.delete_all
        Business.delete_all

        businesses.each do |business|
          import_business(business)
        end
      end

      def import_business(bus)
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
  end
end
