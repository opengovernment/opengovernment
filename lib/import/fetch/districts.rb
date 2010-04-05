module Import::Fetch::Districts
  include Import::Districts

  # Which census datasets will we fetch?
  # See filename conventions at http://www.census.gov/geo/www/cob/filenames.html
  VINTAGE = '06'
  CONGRESS = '110'

  # The special vintage parameter being used for state upper/lower files right now
  # I don't know why it is so.
  ALT_VINTAGE = 'd11'

  # These are just templates - to be evaluated per-state.
  CENSUS_SHP_URL = 'http://www.census.gov/geo/cob/bdy/#{ga}/#{ga}#{vintage_or_congress}shp/'
  CENSUS_SHP_FN = '#{ga}#{fips_code}_#{vintage}_shp.zip'
  
  def self.process
    FileUtils.mkdir_p(DISTRICTS_DIR)
    Dir.chdir(DISTRICTS_DIR)

    # Get the federal data.
    process_one(AREA_CONGRESSIONAL_DISTRICT, CONGRESS_FIPS_CODE, "US Congress")

    # Get state legislature files, when available
    State.find(:all, :conditions => "fips_code is not null").each do |state|
      {"upper" => AREA_STATE_UPPER, "lower" => AREA_STATE_LOWER}.each do |name, house|

        # Unicameral states don't have lower house files.
        unless state.unicameral == true && house == AREA_STATE_LOWER
          process_one(house, state.fips_code, "#{state.name} #{name} house")
        end
      end
    end

    # Cleanup
    `rm *.zip`
  end

  private

  def self.process_one(ga, fips_code, area_name)
    census_fn = census_fn_for(ga, fips_code)
    unless File.exists?(census_fn)
      puts "Downloading the district shapefile for #{area_name}"
      `curl -fO #{census_url_for(ga, fips_code)}`
    end

    unless File.exists?(shpfile_for(census_fn))
      `unzip #{census_fn}`
    end
  end

  def self.census_url_for(ga, fips_code)
    # ga is geographic area - eg. "cd" for congressional district
    # Only provide congress number (eg. 110) if we're looking for congressional districts
    vintage_or_congress = (ga == AREA_CONGRESSIONAL_DISTRICT ? CONGRESS : VINTAGE)
    return eval('"' + CENSUS_SHP_URL + '"') + census_fn_for(ga, fips_code)
  end

  def self.census_fn_for(ga, fips_code)
    fips_code = "%02d" % fips_code
    vintage = (ga == AREA_CONGRESSIONAL_DISTRICT ? CONGRESS : ALT_VINTAGE)
    eval('"' + CENSUS_SHP_FN + '"')
  end

  def self.shpfile_for(zipped_filename)
    zipped_filename.match(/^(.*)_shp.zip$/)[1] + ".shp"
  end

end
