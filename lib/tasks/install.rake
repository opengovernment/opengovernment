# Configuration
require 'yaml'

task :install => ["opengov:install"]

namespace :opengov do
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
  task :prepare => :environment do
    puts "Creating #{Rails.env} database..."
    Rake::Task['db:create'].invoke

    puts "Setting up the #{Rails.env} database"
    Rake::Task['db:create:postgis'].invoke
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:sqlseed'].invoke
  end

  desc "Install db/seeds.sql items"
  task :sqlseed => :environment do
    seeds_fn = File.join(Rails.root, 'db', 'seeds.sql')
    if File.exists?(seeds_fn)
      load_pgsql_files(seeds_fn)
    end
  end

  namespace :create do
    desc "Install PostGIS tables"
    task :postgis => :environment do
      unless ActiveRecord::Base.connection.table_exists?("geometry_columns")
        puts "Installing PostGIS #{POSTGIS_VERSION} tables..."
        if `pg_config` =~ /SHAREDIR = (.*)/
          postgis_dir = File.join($1, 'contrib', "postgis-#{POSTGIS_VERSION}")
          unless File.exists? postgis_dir
            postgis_dir = File.join($1, 'contrib')
          end
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
    FileUtils.mkdir_p(DATA_DIR)
    Dir.chdir(DATA_DIR)
  end

  task :all do
    Rake::Task['fetch:districts'].invoke
    Rake::Task['fetch:bills'].invoke
  end

  desc "Get the district SHP files for Congress and all active states"
  task :districts => :setup do
    OpenGov::Districts.fetch
  end

  desc "Get the fiftystates files for all active states"
  task :bills => :setup do
    OpenGov::Bills.fetch # Note: This also fetches state legislator data
  end
end

desc "Load all data: fixtures, legislatures, districs, committess, people(including their addresses, photos), bills, citations"
namespace :load do
  task :all  => :environment do
    Rake::Task['load:fixtures'].execute
    Rake::Task['load:legislatures'].execute
    Rake::Task['load:districts'].invoke
    Rake::Task['load:committees'].invoke
    Rake::Task['load:people'].invoke
    Rake::Task['load:bills'].invoke
    Rake::Task['load:citations'].invoke
    Rake::Task['load:businesses'].invoke
    Rake::Task['load:contributions'].invoke
    Rake::Task['load:ratings'].invoke
  end

  # These tasks are listed in the order that we need the data to be inserted.
  task :fixtures => :environment do
    require 'active_record/fixtures'

    Dir.chdir(Rails.root)
    Fixtures.create_fixtures('lib/tasks/fixtures', 'legislatures')
    Fixtures.create_fixtures('lib/tasks/fixtures', 'chambers')
    Fixtures.create_fixtures('lib/tasks/fixtures', 'states')
    Fixtures.create_fixtures('lib/tasks/fixtures', 'sessions')

    # Force a reload of the DistrictType class, so we get the proper constants
    class_refresh("Legislature", "Chamber", "UpperChamber", "LowerChamber")
  end

  desc "Fetch and load legislatures from FiftyStates"
  task :legislatures => :environment do
    OpenGov::Legislatures.import!
  end

  desc "Fetch and load addresses from VoteSmart"
  task :addresses => :environment do
    OpenGov::Addresses.import!
  end

  desc "Fetch and load photos from VoteSmart"
  task :photos => :environment do
    OpenGov::Photos.import!
  end

  desc "Fetch and load citations"
  task :citations => :environment do
    OpenGov::Citations.import!
  end

  desc "Fetch and load Wikipedia bios"
  task :bios => :environment do
    OpenGov::.import!
  end

  desc "Load bills from FiftyStates"
  task :bills => :environment do
    puts "Loading bills from Fifty States"
    OpenGov::Bills.import!
    puts "Marking Votesmart Key Votes"
    OpenGov::KeyVotes.import!
  end

  desc "Fetch and load committees from VoteSmart"
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

  desc "Fetch and load people from FiftyStates, GovTrack, VoteSmart, and Wikipedia"
  task :people => :environment do
    OpenGov::People.import!

    Dir.chdir(Rails.root)
    GovTrackImporter.new.import!

    Dir.chdir(Rails.root)
    OpenGov::Addresses.import!
    OpenGov::Photos.import!
    OpenGov::Bios.import!    
  end

  desc "Fetch and load people ratings VoteSmart"
  task :ratings => :environment do
    OpenGov::Ratings.import!
  end

  task :districts => :environment do
    Dir.glob(File.join(DISTRICTS_DIR, '*.shp')).each do |shpfile|
      OpenGov::Districts::import!(shpfile)
    end

    class_refresh("District")
  end

  def class_refresh(*class_names)
    class_names.each do |klass_name|
      Object.class_eval do
        remove_const(klass_name) if const_defined?(klass_name)
      end
      load klass_name.tableize.singularize + ".rb"
    end
  end
end


