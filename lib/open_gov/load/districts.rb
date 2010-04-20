module OpenGov::Load::Districts
  include OpenGov::District

  AT_LARGE_LSADS = ['c1', 'c4'].freeze

  def self.import!(shpfile)
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

      state = State.find(:first, :conditions => {:fips_code => shape.state})
      if [AREA_STATE_LOWER, AREA_STATE_UPPER].include?(table_type)
        legislature = Legislature.find_by_state_id(state)
      else
        # It's federal; so it's always congress.
        legislature = Legislature::CONGRESS
      end

      if legislature
        # We're not using the LSAD for state houses, because
        # there are lots of LSADs we don't care about.
        chamber = case table_type
        when AREA_STATE_UPPER then
          UpperChamber.find_by_legislature_id(legislature)
        when AREA_STATE_LOWER, AREA_CONGRESSIONAL_DISTRICT then
          LowerChamber.find_by_legislature_id(legislature)
        else
          raise "Unsupported table type #{table_type} encountered"
        end

        vintage = case table_type
        when AREA_STATE_LOWER, AREA_STATE_UPPER # State
          OpenGov::Fetch::Districts::VINTAGE
        else # Federal
          OpenGov::Fetch::Districts::CONGRESS
        end

        census_sld = shape[:cd] || shape[:sldl] || shape[:sldu]

    #    District.delete_all(
    #      :vintage => vintage,
    #      :census_sld => census_sld,
    #      :census_district_type => census_district_type,
    #      :state => state)

        d = District.create(
          :name => district_name_for(shape),
          :vintage => vintage,
          :state => state,
          :chamber => chamber,
          :at_large => AT_LARGE_LSADS.include?(shape.lsad.downcase),
          :census_sld => census_sld,
          :census_district_type => shape.lsad,
          :geom => shape.the_geom
        )

      end

    end

    puts "Dropping #{table_name} conversion table"
    OpenGov::Parse::Shapefile.cleanup(shpfile)
  end

  def self.district_name_for(shape)
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