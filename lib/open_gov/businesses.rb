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

        sector = Sector.find_or_create_by_name_and_nimsp_code(bus.sector_name, bus.imsp_sector_code)

        industry = Industry.find_or_initialize_by_name_and_nimsp_code(bus.industry_name, bus.imsp_industry_code)
        industry.parent = sector
        industry.save

        business = Business.find_or_initialize_by_name(bus.business_name)
        business.parent = industry
        business.save

      end
    end
  end
end
