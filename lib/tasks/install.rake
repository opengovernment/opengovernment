# Configuration
require 'yaml'

desc "Install OpenGovernment under the current Rails env"
task :install => :environment do
  abcs = ActiveRecord::Base.configurations
  if abcs[Rails.env]["adapter"] != 'postgresql'
    raise "Sorry, OpenGovernment requires PostgreSQL"
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
    desc "Install PostGIS tables"
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
    Rake::Task['fetch:states'].execute
    Rake::Task['fetch:people'].execute
  end

  task :setup => :environment do
    FileUtils.mkdir_p(DATA_DIR)
    Dir.chdir(DATA_DIR)
  end

  desc "Get the district SHP files for Congress and all active states"
  task :districts => :setup do
    OpenGov::Fetch::Districts.process
  end
  
  task :states => :setup do
    OpenGov::Fetch::States.process
  end

  task :states => :setup do
    OpenGov::Fetch::People.process
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
    include OpenGov::District
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
      OpenGov::District::import!(shpfile)
    end
  end

  task :states => :setup do
    require 'active_record/fixtures'

    Dir.chdir(Rails.root)
    Fixtures.create_fixtures('lib/tasks/fixtures', 'states')
  end
end

