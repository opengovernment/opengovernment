# Configuration
require 'yaml'

desc "Install OpenGovernment under the current Rails env"
task :install => :environment do
  abcs = ActiveRecord::Base.configurations
  if abcs[Rails.env]["adapter"] != 'postgresql'
    raise "Sorry, OpenGovernment requires PostgreSQL 8.4"
  end

  puts "Creating #{Rails.env} database..."
  Rake::Task['db:create'].invoke

  Rake::Task['db:create:postgis'].invoke

  puts "Setting up the #{Rails.env} database"
  Rake::Task['db:migrate'].invoke
  
  # Core internal data
  Rake::Task['install:data'].invoke
end

namespace :db do
  namespace :create do
    task :postgis => :environment do

      unless ActiveRecord::Base.connection.table_exists?("geometry_columns")
        puts "Installing PostGIS #{POSTGIS_VERSION} tables..."
        if `pg_config` =~ /SHAREDIR = (.*)/
          postgis_dir = File.join($1, 'contrib', "postgis-#{POSTGIS_VERSION}")
        else
          raise "Could not find pg_config; please install PostgreSQL and PostGIS #{POSTGIS_VERSION}"
        end

        abcs = ActiveRecord::Base.configurations
        ENV['PGHOST']     = abcs[Rails.env]["host"] if abcs[Rails.env]["host"]
        ENV['PGPORT']     = abcs[Rails.env]["port"].to_s if abcs[Rails.env]["port"]
        ENV['PGPASSWORD'] = abcs[Rails.env]["password"].to_s if abcs[Rails.env]["password"]

        `createlang plpgsql -U "#{abcs[Rails.env]["username"]}" #{abcs[Rails.env]["database"]}`
        
        ['postgis.sql', 'spatial_ref_sys.sql'].each do |fn|
          `psql -U "#{abcs[Rails.env]["username"]}" -f #{File.join(postgis_dir, fn)} #{abcs[Rails.env]["database"]}`
        end
      end
    end
  end
end

namespace :install do
  desc "Download and insert all core data"
  task :data => :environment do
    # Fixtures
    Rake::Task['load:states'].invoke

    # Fetch all exteral data
    Rake::Task['fetch:all'].invoke

    # Load external data
    Rake::Task['load:districts'].invoke
  end
end

namespace :fetch do
  task :all do
    Rake::Task['fetch:districts'].invoke
  end

  task :setup => :environment do
    FileUtils.mkdir_p(DATA_DIR)
    Dir.chdir(DATA_DIR)
  end

  desc "Get the district SHP files for Congress and all active states"
  task :districts => :setup do
    Import::Fetch::Districts.process
  end
end

namespace :load do
  task :all => :setup do
    Rake::Task['load:states'].execute
    Rake::Task['load:districts'].execute
  end
  
  task :setup => :environment do
    Dir.chdir(DATA_DIR)
  end

  task :districts => :setup do
    include Import::Districts
    require 'active_record/fixtures'

    puts "Setting up district types"
    Dir.chdir(Rails.root)
    Fixtures.create_fixtures('lib/tasks/fixtures', 'district_types')
    
    # Force a reload of the DistrictType class, so we get the proper constants
    Object.class_eval do
      remove_const("DistrictType") if const_defined?("DistrictType")
    end
    load "district_type.rb"

    Dir.chdir(DATA_DIR)

    Dir.glob(File.join(DISTRICTS_DIR, '*.shp')).each do |shpfile|        

      puts "Inserting shapefile #{File.basename(shpfile)}"
      insert_shapefile shpfile

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
          Import::Fetch::Districts::VINTAGE
        else # Federal
          Import::Fetch::Districts::CONGRESS
        end

        d = District.create(
          :name => district_name_for(shape),
          :district_type => district_type,
          :vintage => vintage,
          :state => State.find(:first, :conditions => {:fips_code => shape.state}),
          :census_sld => shape[:cd] || shape[:sldl] || shape[:sldu],
          :geom => shape.the_geom
        )
      end

      puts "Dropping #{table_name} conversion table"
      Import::Parse::Shapefile.cleanup(shpfile)
    end

    #if CONGRESSIONAL_SHP_FILE =~ /(.*)\.shp/
    #  table_name = $1.downcase
    
    #  if ActiveRecord::Base.connection.table_exists?(table_name)
    #    ActiveRecord::Schema.execute "insert into districts"
    #  end
    #end
    
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

  task :states => :setup do
    require 'active_record/fixtures'

    Dir.chdir(Rails.root)
    Fixtures.create_fixtures('lib/tasks/fixtures', 'states')
  end
end

def insert_shapefile(fn)
  Import::Parse::Shapefile.process(fn, :drop_table => true)
end
