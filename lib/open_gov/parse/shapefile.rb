module OpenGov::Parse::Shapefile
  def self.to_sql(shapefile, table_name)
    `shp2pgsql -c -D -s #{::District::SRID} -i -I #{shapefile} #{table_name} > #{File.join(File.dirname(shapefile), table_name)}.sql`
  end

  def self.process(shapefile, opts = {})

    drop_table = opts[:drop_table] || false

    #add options depending on the type of database
    if ActiveRecord::Base.connection.is_a?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
      table_options = "TYPE=MyISAM" #for MySQL <= 5.0.16 : only MyISAM tables support geometric types
    else
      table_options = ""
    end

    shp_filename = shapefile
    shp_basename = File.basename(shapefile)

    raise "File not found" unless File.exist?(shp_filename)

    if shp_basename =~ /(.*)\.shp/
      table_name = $1.downcase

      #drop in case it already exists
      if ActiveRecord::Base.connection.table_exists?(table_name)
        raise "Table already exists; try again with :drop_table => true option to drop." unless drop_table
        ActiveRecord::Schema.drop_table(table_name)
      end
    end

    # This creates an SQL file in the same directory as the shapefile
    to_sql(shp_filename, table_name)

    abcs = ActiveRecord::Base.configurations
    ENV['PGHOST']     = abcs[Rails.env]["host"] if abcs[Rails.env]["host"]
    ENV['PGPORT']     = abcs[Rails.env]["port"].to_s if abcs[Rails.env]["port"]
    ENV['PGPASSWORD'] = abcs[Rails.env]["password"].to_s if abcs[Rails.env]["password"]

    # Parse our shape SQL file
    `psql -U "#{abcs[Rails.env]["username"]}" -f #{File.join(File.dirname(shapefile), table_name)}.sql #{abcs[Rails.env]["database"]}`
  end

  def self.cleanup(shapefile)
    shp_filename = shapefile
    shp_basename = File.basename(shapefile)

    raise "File not found" unless File.exist?(shp_filename)

    if shp_basename =~ /(.*)\.shp/
      table_name = $1.downcase

      #drop the table if it exists
      if ActiveRecord::Base.connection.table_exists?(table_name)
        ActiveRecord::Schema.drop_table(table_name)
      end
    end

  end

  private
  
  def self.shp_field_type_2_rails(type)
    case type
    when 'N' then :integer
    when 'F' then :float
    when 'D' then :date
    else
      :string
    end
  end

  def self.shp_geom_type_2_rails(type)
    case type
    when ShpType::POINT then :point
    when ShpType::POLYLINE then :multi_line_string
    when ShpType::POLYGON then :multi_polygon
    when ShpType::MULTIPOINT then :multi_point 
    end
  end

  
end
