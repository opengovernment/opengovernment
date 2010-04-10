module OpenGov::District

  # The special FIPS code used for federal/congressional data
  CONGRESS_FIPS_CODE = '99'

  # Abbreviations for geographic area codes (ga)
  AREA_CONGRESSIONAL_DISTRICT = 'cd'
  AREA_STATE_UPPER = 'su'
  AREA_STATE_LOWER = 'sl'
  
  # The geographic SRID used for all Census bureau data
  CENSUS_SRID = 4269

  def import!(shpfile)
    puts "Inserting shapefile #{File.basename(shpfile)}"
    OpenGov::Parse::Shapefile.process(shpfile, :drop_table => true)

    table_name = File.basename(shpfile, '.shp')
    puts "Migrating #{table_name} table into districts"

    arTable = Class.new(ActiveRecord::Base) do
      set_table_name table_name
    end
    
    # All tables will have at least:
    # - state (fips_code)
    # - the_geom (geometry)
    # - lsad (district type)

    # If table_name starts with sl:
    # - sldl (district number, or ZZZ for undistricted areas)

    # If it starts with su:
    # - sldu (district number, or ZZZ)
    
    # and if it starts with cd:
    # - cd (district number, or 00 for at large)
    table_type = table_name[0, 2]

    arTable.find(:all).each do |shape|
      
      # We're not using the LSAD for state houses, because
      # there are lots of LSADs we don't care about.
      district_type = case table_type
      when AREA_STATE_LOWER then
        DistrictType::LL
      when AREA_STATE_UPPER then
        DistrictType::LU
      when AREA_CONGRESSIONAL_DISTRICT then
        eval("DistrictType::#{shape.lsad.upcase}")
      else
        raise "Unsupported table type #{table_type} encountered"
      end

      vintage = case table_type
      when AREA_STATE_LOWER, AREA_STATE_UPPER # State
        OpenGov::Fetch::Districts::VINTAGE
      else # Federal
        OpenGov::Fetch::Districts::CONGRESS
      end

      d = ::District.create(
        :name => district_name_for(shape),
        :district_type => district_type,
        :vintage => vintage,
        :state => State.find(:first, :conditions => {:fips_code => shape.state}),
        :census_sld => shape[:cd] || shape[:sldl] || shape[:sldu],
        :geom => shape.the_geom
      )
    end

    puts "Dropping #{table_name} conversion table"
    OpenGov::Parse::Shapefile.cleanup(shpfile)
  end

  def district_name_for(shape)
    census_name_column = (shape[:cd] || shape[:name])      
    fips_code = shape.state.to_i
    
    # Some states have sane district names in the dataset
    # We check via the FIPS codes.
    if [32, 25].include?(fips_code)
      census_name_column
    elsif fips_code == 50        
      # These have names like "Orleans-Caledonia-1"
      "District " + census_name_column
    elsif fips_code == 33 && shape.lsad == "LL"  
      "District " + census_name_column
    else
      "District " + census_name_column.to_i.to_s
    end
  end
  
end