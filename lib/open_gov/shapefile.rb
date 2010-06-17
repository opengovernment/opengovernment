module OpenGov
  class Shapefile < Resources
    class << self
      def to_sql(shapefile, table_name)
        `shp2pgsql -c -D -s #{::District::SRID} -i -I #{shapefile} #{table_name} > #{File.join(File.dirname(shapefile), table_name)}.sql`
      end

      def process(shapefile, opts = {})
        drop_table = opts[:drop_table] || false

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

      def cleanup(shapefile)
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
    end
  end
end
