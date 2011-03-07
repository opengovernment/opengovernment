module OpenGov
  class Industries < Resources
    # TODO: This should be more cleanly separated from contributions --
    # so we don't have to delete all contributions when we load industries (the second time)

    def fetch
      industries = GovKit::TransparencyData::Categories.all
      puts "Fetched #{industries.size} industries from TransparencyData"
      industries
    end

    def import
      industries = fetch
      puts "Deleting existing industries and contributions.."
      Contribution.delete_all
      Industry.delete_all

      industries.each do |industry|
        import_industry(industry)
      end
    end

    def import_industry(row)
      puts "Importing: #{row[:name]}"

      industry = Industry.find_or_initialize_by_name(row[:name].titleize)
      industry.parent_name = row[:industry].titleize
      industry.transparencydata_code = row[:code]
      industry.transparencydata_order = row[:order]
      industry.save
    end
  end
end
