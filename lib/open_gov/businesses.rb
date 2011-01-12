module OpenGov
  class Businesses < Resources
    # TODO: This should be more cleanly separated from contributions --
    # so we don't have to delete all contributions when we load businesses (the second time)

    def self.fetch
      businesses = GovKit::TransparencyData::Categories.all
      puts "Fetched #{businesses.size} businesses from FollowTheMoney"
      businesses
    end

    def self.import!
      businesses = fetch
      puts "Deleting existing businesses and contributions.."
      Contribution.delete_all
      CorporateEntity.delete_all

      businesses.each do |business|
        import_business(business)
      end
    end

    def self.import_business(bus)
      puts "Importing: #{bus[:name]}"
 
      Industry.transaction do
        industry = Industry.find_or_create_by_name(bus[:industry])
        industry.save

#        industry = Industry.find_or_create_by_nimsp_code(bus.imsp_industry_code) 
#        industry.name = bus.industry_name
#        industry.sector_id = sector.id
#        industry.save
#
        business = Business.find_or_initialize_by_name(bus[:name])
#        business.sector_id = sector.id
        business.industry_id = industry.id
        business.transparencydata_'m thcode = bus[:code]
        business.save
      end
    end
  end
end
