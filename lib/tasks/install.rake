# Configuration
require 'yaml'


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

end

desc "Prepare the database: load schema, load sql seeds, load postgis tables"
namespace :db do

  namespace :test do
    # TODO: This is a big tricksy. I'd rather find a smoother way to get the CI
    # server not to run db:test:prepare when trying to run tests.
    remove_task :"db:test:prepare"
    desc "Noop"
    task :prepare do
      puts "Run RAILS_ENV=test rake db:drop db:prepare instead."
    end
  end

  desc "Prepare the database: load schema, load sql seeds, load postgis tables"
  task :prepare => :environment do
    puts "\n---------- Creating #{Rails.env} database."
    Rake::Task['db:create'].invoke

    puts "\n---------- Setting up the #{Rails.env} database."
    Rake::Task['db:create:postgis'].invoke

    unless ActiveRecord::Base.connection.table_exists?("schema_migrations")
      Rake::Task['db:schema:load'].invoke
    end

    puts "\n---------- Loading seed data file"
    Rake::Task['db:sqlseed'].invoke

    puts "\n---------- Loading database fixtures"
    Rake::Task['load:fixtures'].execute
  end

  desc "Install db/seeds.sql items"
  task :sqlseed => :environment do
    seeds_fn = File.join(Rails.root, 'db', 'seeds.sql')
    if File.exists?(seeds_fn)
      load_pgsql_files(seeds_fn)
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
    FileUtils.mkdir_p(Settings.data_dir)
    Dir.chdir(Settings.data_dir)
  end

  task :all do
    Rake::Task['fetch:districts'].invoke
    Rake::Task['fetch:openstates'].invoke
  end

  desc "Get the district SHP files for Congress and all active states"
  task :districts => :setup do
    with_states do |state|
      state ? OpenGov::Districts.fetch_one(state) : OpenGov::Districts.fetch!
    end
  end

  desc "Get the openstates files for all active states"
  task :openstates => :setup do
    # Download the bills & legislator data from OpenStates.

    with_states do |state|
      state ? OpenGov::OpenStates.fetch_one(state) : OpenGov::OpenStates.fetch!
    end
  end

  desc "Fetch photos and attach them to people"
  task :photo_thumbs => :environment do
    OpenGov::Photos.sync!
  end
end

desc "Load all data: fixtures, legislatures, districs, committess, people(including their addresses, photos), bills, citations"
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
    puts "\n---------- Loading news & blog citations"
    Rake::Task['load:citations'].invoke
    puts "\n---------- Loading PVS contribution and ratings data"
    Rake::Task['load:businesses'].invoke
    Rake::Task['load:contributions'].invoke
    Rake::Task['load:ratings'].invoke
  end

  # These tasks are listed in the order that we need the data to be inserted.
  task :fixtures => :environment do
    require 'active_record/fixtures'


    if Rails.env == 'test'
      Fixtures.reset_cache
      fixtures_folder = File.join(Rails.root, 'spec', 'fixtures')
      fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
      Fixtures.create_fixtures(fixtures_folder, fixtures)
    else
      Dir.chdir(Rails.root)
      Fixtures.create_fixtures('lib/tasks/fixtures', 'legislatures')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'chambers')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'states')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'sessions')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'tags')
    end

    # Force a reload of the DistrictType class, so we get the proper constants
    class_refresh("Legislature", "Chamber", "UpperChamber", "LowerChamber")
  end

  desc "Fetch and load legislatures from Open State data"
  task :legislatures => :environment do
    with_states do |state|
      state ? OpenGov::Legislatures.import_one(state) : OpenGov::Legislatures.import!
    end
  end

  desc "Fetch and load citations"
  task :citations => :environment do
    OpenGov::Citations.import!
  end

  desc "Load bills from Open State data"
  task :bills => :environment do
    puts "Loading bills from Open State data"
    with_states do |state|
      if state
        OpenGov::Bills.import_one(state)
        OpenGov::KeyVotes.import_one(state)
      else
        OpenGov::Bills.import!
        OpenGov::KeyVotes.import!
      end
    end
  end

  desc "Fetch and load committees from OpenStates"
  task :committees => :environment do
    OpenGov::Committees.import!
  end

  desc "Fetch and load businesses from FollowTheMoney"
  task :businesses => :environment do
    OpenGov::Businesses.import!
  end

  desc "Fetch and load contributions from FollowTheMoney"
  task :contributions => :environment do
    OpenGov::Contributions.import!
  end

  desc "Fetch and load people from OpenStates, GovTrack, VoteSmart, and Wikipedia"
  task :people => :environment do
    with_states do |state|
      state ? OpenGov::People.import_one(state) : OpenGov::People.import!
    end

    Dir.chdir(Rails.root)
    GovTrackImporter.new.import!

    # These methods all act on all people with votesmart ids
    Dir.chdir(Rails.root)
    OpenGov::Addresses.import!
    OpenGov::Photos.import!
    puts "---------- Importing bios from VoteSmart."
    OpenGov::Bios.import!
  end

  desc "Fetch and load people ratings VoteSmart"
  task :ratings => :environment do
    OpenGov::Ratings.import!
  end

  task :districts => :environment do
    Dir.glob(File.join(Settings.districts_dir, '*.shp')).each do |shpfile|
      OpenGov::Districts::import!(shpfile)
    end

    class_refresh("District")
  end

end

