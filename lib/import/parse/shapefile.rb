include GeoRuby::Shp4r

module Import::Parse::Shapefile

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

      #empty block : the columns will be added afterwards
      ActiveRecord::Schema.create_table(table_name, :options => table_options){}

      ShpFile.open(shp_filename.to_s) do |shapes|
        shapes.fields.each do |field|
          ActiveRecord::Schema.add_column(table_name, field.name.downcase, shp_field_type_2_rails(field.type))
        end

        #add the geometric column in the_geom
        ActiveRecord::Schema.add_column(table_name, :the_geom, shp_geom_type_2_rails(shapes.shp_type), :null => false)
        
        #add an index
        ActiveRecord::Schema.add_index(table_name, :the_geom, :spatial => true)

        #add the data
        #create a subclass of ActiveRecord::Base wired to the table just created
        arTable = Class.new(ActiveRecord::Base) do
          set_table_name table_name
        end

        #go though all the shapes in the file
        shapes.each do |shape|
          #create an ActiveRecord object
          record = arTable.new

          #fill the fields
          shapes.fields.each do |field|
            record[field.name.downcase] = shape.data[field.name]
          end

          #fill the geometry
          record.the_geom = shape.geometry

          #save to the database
          record.save
        end
      end
    end
  end

  def self.cleanup(shapefile)
    shp_filename = shapefile
    shp_basename = File.basename(shapefile)

    raise "File not found" unless File.exist?(shp_filename)

    if shp_basename =~ /(.*)\.shp/
      table_name = $1.downcase

      #drop the table if it exists
      if ActiveRecord::Base.connection.table_exists?(table_name)
        ActiveRecord::Schema.remove_index(table_name, :the_geom)
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
