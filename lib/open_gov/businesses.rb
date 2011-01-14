module OpenGov
  class Businesses < Resources
    # TODO: This should be more cleanly separated from contributions --
    # so we don't have to delete all contributions when we load businesses (the second time)

    def self.fetch
      industries = GovKit::TransparencyData::Categories.all
      puts "Fetched #{industries.size} industries from TransparencyData"
      industries
    end

    def self.import!
      industries = fetch
      puts "Deleting existing businesses and contributions.."
      Contribution.delete_all
      CorporateEntity.delete_all

      industries.each do |industry|
        import_industry(industry)
      end
    end

    def self.import_industry(row)
      puts "Importing: #{row[:name]}"

      industry = Industry.find_or_initialize_by_name(row[:name].titleize)
      industry.parent_name = row[:industry].titleize
      industry.transparencydata_code = row[:code]
      industry.transparencydata_order = row[:order]
      industry.save
#        industry = Industry.find_or_create_by_nimsp_code(bus.imsp_industry_code) 
#        industry.name = bus.industry_name
#        industry.sector_id = sector.id
#        industry.save
#
#        business = Business.find_or_initialize_by_name(bus[:name])
#        business.sector_id = sector.id
#        business.industry_id = industry.id
#        business.transparencydata_code = bus[:code]
#        business.transparencydata_order = bus[:order]
#        business.save
    end
  end
end
