# Configuration
require 'yaml'
require 'active_record/fixtures'

# Some helper methods so that we can remove a task preloaded by another .rake file.
Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

# For loading specific states:
# Either yield a nil if no states were specified, or yield each state individually.
def with_states

  unless ENV['LOAD_STATES']
    yield nil
    return
  end

  ENV['LOAD_STATES'].split(',').each do |state_abbrev|
    if state = State.find_by_abbrev(state_abbrev.strip.upcase)
      yield state
    else
      puts "Could not find state #{state_abbrev}; skipping."
    end
  end
end

# Reload a given class file.
def class_refresh(*class_names)
  class_names.each do |klass_name|
    Object.class_eval do
      remove_const(klass_name) if const_defined?(klass_name)
    end
    load klass_name.tableize.singularize + ".rb"
  end
end


task :install => ["opengov:install"]
task :install_dev => ["opengov:install_dev"]

namespace :opengov do
  task :prepare do
    # Get ready to run tests -- on the CI server

    if ENV['SHARED_CONFIG_DIR']
      # All files in our external config dir will be symlinked to the local config dir if they don't already
      # exist in that dir. This is mainly used for TeamCity CI.
      config_dir = File.join(Rails.root, 'config')
      all_files = File.join(ENV['SHARED_CONFIG_DIR'], "*")
      Dir.glob(all_files).each_with_index do |file, i|
        unless File.exists?(File.join(config_dir, File.basename(file)))
          system "ln -s #{file} #{File.join(config_dir, File.basename(file))}"
        end
      end
    end
  end

  desc "Install clean database: prepare database, fetch all data, load data"
  task :install => :environment do
    abcs = ActiveRecord::Base.configurations

    unless abcs[Rails.env]["adapter"] == 'postgresql'
      raise "Sorry, OpenGovernment requires PostgreSQL"
    end

    Rake::Task['db:prepare'].invoke
    Rake::Task['fetch:all'].invoke
    Rake::Task['load:all'].invoke
  end

  desc "Set up an initial dev environment (with minimal data import)"
  task :install_dev => :environment do
    Rake::Task['db:prepare'].invoke
    Rake::Task['fetch:geoip'].invoke
    Rake::Task['load:dev'].invoke
  end

end

desc "Prepare the database: load schema, load sql seeds, load postgis tables"
namespace :db do

  namespace :test do
    # TODO: This is a big tricksy. I'd rather find a smoother way to get the CI
    # server not to run db:test:prepare when trying to run tests.
    remove_task :"db:test:prepare"
    
    task :prepare => ["db:reset"]
  end

  desc "Create database w/postgis, full schema, and additional DDL"
  task :prepare_without_fixtures => :environment do
    puts "\n---------- Creating #{Rails.env} database."
    Rake::Task['db:create'].invoke

    puts "\n---------- Setting up the #{Rails.env} database."
    Rake::Task['db:create:postgis'].invoke

    unless ActiveRecord::Base.connection.table_exists?("schema_migrations")
      Rake::Task['db:schema:load'].invoke
    end

    puts "\n---------- Loading additional DDL"
    Rake::Task['db:seed:ddl'].invoke
  end

  desc "Prepare the database: load postgis, schema, DDL, and "
  task :prepare => :environment do
    Rake::Task['db:prepare_without_fixtures'].invoke

    puts "\n---------- Loading database fixtures"
    Rake::Task['load:fixtures:seed'].execute
  end

  desc 'Drop and create the current RAILS_ENV database'
  task :reset => :environment do
    puts "Resetting the database for #{Rails.env}".upcase
    Rake::Task['db:drop'].invoke
    Rake::Task['db:prepare_without_fixtures'].invoke
    Rake::Task['load:fixtures'].invoke
  end

  desc 'Drop, create, and seed the current RAILS_ENV database using test fixtures from spec/fixtures'
  task :reset_dev => :environment do
    puts "Resetting the database for #{Rails.env}".upcase
    Rake::Task['db:reset'].invoke
    Rake::Task['load:dev'].invoke
    puts "Success!"
  end

  namespace :seed do
    desc "Install db/ddl.sql items"
    task :ddl => :environment do
      puts "NOTE: You may safely ignore PostgreSQL 'does not exist' errors"
      seeds_fn = File.dirname(__FILE__) + '/../../db/seeds/ddl.sql'
      if File.exists?(seeds_fn)
        load_pgsql_files(seeds_fn)
      end
    end
    
    desc "Load seed data for dev environment"
    task :dev => :environment do
      puts "Seeding the #{Rails.env} database."
      require File.dirname(__FILE__) + '/../../db/seeds/dev'
    end
  end

  #TODO: Remove duplication between create, drop postgis tasks
  namespace :create do
    desc "Install PostGIS tables"
    task :postgis => :environment do
      unless ActiveRecord::Base.connection.table_exists?("geometry_columns")
        puts "\n---------- Installing PostGIS tables"
        # Find PostGIS
        if `pg_config` =~ /SHAREDIR = (.*)/
          postgis_dir = Dir.glob(File.join($1, 'contrib', 'postgis-*')).last || File.join($1, 'contrib')
          raise "Could not find PostGIS" unless File.exists? postgis_dir
        else
          raise "Could not find pg_config; please install PostgreSQL and PostGIS #{POSTGIS_VERSION}"
        end

        if File.exists?(File.join(postgis_dir, 'postgis.sql'))
          load_pgsql_files(File.join(postgis_dir, 'postgis.sql'),
                           File.join(postgis_dir, 'spatial_ref_sys.sql'))
        else
          raise "Please install PostGIS before continuing."
        end

      else
        puts "Looks like you already have PostGIS installed in your database. No action taken."
      end
    end
  end

  def load_pgsql_files(*fns)
    abcs = ActiveRecord::Base.configurations
    ENV['PGHOST']     = abcs[Rails.env]["host"] if abcs[Rails.env]["host"]
    ENV['PGPORT']     = abcs[Rails.env]["port"].to_s if abcs[Rails.env]["port"]
    ENV['PGPASSWORD'] = abcs[Rails.env]["password"].to_s if abcs[Rails.env]["password"]

    `createlang plpgsql -U "#{abcs[Rails.env]["username"]}" #{abcs[Rails.env]["database"]}`

    fns.each do |fn|
      `psql -U "#{abcs[Rails.env]["username"]}" -f #{fn} #{abcs[Rails.env]["database"]}`
    end
  end
end

desc "Fetch Data: districts, bills"
namespace :fetch do
  task :setup => :environment do
    puts "Setup for fetch"
    FileUtils.mkdir_p(Settings.data_dir)
    Dir.chdir(Settings.data_dir)
  end

  task :all do
    Rake::Task['fetch:districts'].invoke
    Rake::Task['fetch:openstates'].invoke
    Rake::Task['fetch:geoip'].invoke
  end

  desc "Get the district SHP files for Congress and all active states"
  task :districts => :setup do
    with_states do |state|
      state ? OpenGov::Districts.fetch_one(state) : OpenGov::Districts.fetch!
    end
  end

  desc "Fetch latest GeoIP dataset (updated monthly)"
  task :geoip => :setup do
    geoip_url = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'

    puts "---------- Downloading GeoIP datafile"
    `curl -fO #{geoip_url}`
    `gzip -df #{File.basename(geoip_url)}`
  end

  desc "Get the openstates files for all active states"
  task :openstates => :setup do
    # Download the bills & legislator data from OpenStates.

    with_states do |state|
      state ? OpenGov::OpenStates.fetch_one(state) : OpenGov::OpenStates.fetch!
    end
  end
end

desc "Load all data: fixtures, legislatures, districs, committess, people(including their addresses, photos), bills, mentions"
namespace :load do
  task :all  => :environment do
    # We don't load fixtures here anymore-- we load them earlier so we can use them to fetch the right districts and bills.

    puts "\n---------- Loading legislatures and districts"
    Rake::Task['load:legislatures'].execute
    Rake::Task['load:districts'].invoke
    puts "\n---------- Loading people"
    Rake::Task['load:people'].invoke
    puts "\n---------- Loading committees and committee memberships"
    Rake::Task['load:committees'].invoke
    puts "\n---------- Loading bills"
    Rake::Task['load:bills'].invoke
    puts "\n---------- Loading news & blog mentions"
    Rake::Task['load:mentions'].invoke
    puts "\n---------- Loading PVS contribution and ratings data"
    Rake::Task['load:industries'].invoke
    Rake::Task['load:contributions'].invoke
    Rake::Task['load:ratings'].invoke
    puts "\n---------- Fetch VoteSmart photos and attach them to people"
    Rake::Task['sync:photos'].invoke
  end
  
  desc "Load test fixtues and key imported data into the dev environment"
  task :dev => :environment do
    Rake::Task['load:fixtures:test'].invoke
    OpenGov::Ratings.import_categories
  end    

  namespace :fixtures do
    desc "Load fixtures for dev / testing"
    task :test => :environment do
      Fixtures.reset_cache
      fixtures_folder = File.join(Rails.root, 'spec', 'fixtures')
      fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
      Fixtures.create_fixtures(fixtures_folder, fixtures)

      # Force a reload of the DistrictType class, so we get the proper constants
      class_refresh("Legislature", "Chamber", "UpperChamber", "LowerChamber")
    end

    desc "Load fixtures for full production/staging import"
    task :seed => :environment do
      Dir.chdir(Rails.root)
      Fixtures.create_fixtures('lib/tasks/fixtures', 'legislatures')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'chambers')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'states')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'sessions')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'tags')

      # Force a reload of the DistrictType class, so we get the proper constants
      class_refresh("Legislature", "Chamber", "UpperChamber", "LowerChamber")
    end

  end

  desc "Load test fixtures if RAILS_ENV=test, else load production/staging fixtures"
  task :fixtures => :environment do
    if Rails.env == 'test'
      Rake::Task['load:fixtures:test'].invoke
    else
      Rake::Task['load:fixtures:seed'].invoke
    end
  end

  desc "Fetch and load legislatures from Open State data"
  task :legislatures => :environment do
    with_states do |state|
      state ? OpenGov::Legislatures.import_state(state) : OpenGov::Legislatures.import!
    end
  end

  desc "Fetch and load mentions"
  task :mentions => :environment do
    OpenGov::Mentions.import!
  end

  desc "Load bills from Open State data"
  task :bills => :environment do
    puts "Loading bills from Open State data"
    with_states do |state|
      if state
        OpenGov::Bills.import_state(state)
        OpenGov::KeyVotes.import_state(state)
      else
        OpenGov::Bills.import!
        OpenGov::KeyVotes.import!
      end
    end
  end

  desc "Fetch and load committees from OpenStates"
  task :committees => :environment do
    with_states do |state|
      state ? OpenGov::Committees.import_state(state) : OpenGov::Committees.import!
    end 
  end

  desc "Fetch and load industries from FollowTheMoney"
  task :industries => :environment do
    OpenGov::Industries.import!
  end

  desc "Queue fetch and load of contributions from FollowTheMoney"
  task :contributions => :environment do
    with_states do |state|
      state ? OpenGov::Contributions.new.import_state(state) : OpenGov::Contributions.new.import
    end
  end

  desc "Fetch and load people from OpenStates, GovTrack, VoteSmart, and Wikipedia"
  task :people => :environment do
    with_states do |state|
      state ? OpenGov::People.import_state(state) : OpenGov::People.import!
    end

    Dir.chdir(Rails.root)
    GovTrackImporter.new.import!

    # These methods all act on all people with votesmart ids
    Dir.chdir(Rails.root)
    OpenGov::Addresses.import!

    puts "---------- Importing bios from Wikipedia."
    OpenGov::Bios.import!
  end

  desc "Fetch and load people ratings VoteSmart"
  task :ratings => :environment do
    OpenGov::Ratings.import!
  end

  desc "Fetch and import Census Bureau congressional and legislative district boundaries"
  task :districts => :environment do
    Dir.glob(File.join(Settings.districts_dir, '*.shp')).each do |shpfile|
      OpenGov::Districts::import!(shpfile)
    end

    class_refresh("District")
  end

end

