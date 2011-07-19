# Configuration
require 'yaml'
require 'active_record/fixtures'
require File.dirname(__FILE__) + "/rake_extensions"

task :install => ["opengov:install"]
task :install_dev => ["opengov:install_dev"]

task :launch_state => :environment do
  with_states do |state|
    state ? state.update_attribute(:launch_date, Time.now) : puts("Nothing performed; use LOAD_STATES to specify which states to launch.")
  end
end

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

    if State.table_exists? && State.count > 0
      puts "It appears you've already run rake install; skipping DB setup and fixture imports."
    else
      Rake::Task['db:prepare'].invoke
    end
    Rake::Task['fetch:all'].invoke
    Rake::Task['load:all'].invoke
  end

  desc "Set up an initial dev environment (with minimal data import)"
  task :install_dev do
    Rake::Task['db:prepare'].invoke
    Rake::Task['fetch:geoip'].invoke
    Rake::Task['load:dev'].invoke
  end

end


desc "Fetch Data: districts, bills"
namespace :fetch do
  task :setup => :environment do
    FileUtils.mkdir_p(Settings.data_dir)
    Dir.chdir(Settings.data_dir)
  end

  task :all do
    Rake::Task['fetch:boundaries'].invoke
    Rake::Task['fetch:openstates'].invoke
    Rake::Task['fetch:geoip'].invoke
  end

  desc "Get the SHP files for Congress, all active state SLDs, all state boundaries, and ZCTAs"
  task :boundaries => :setup do
    with_states do |state|
      state ? OpenGov::Boundaries.new.fetch_one(state) : OpenGov::Boundaries.new.fetch
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
      state ? OpenGov::OpenStates.new.fetch_one(state) : OpenGov::OpenStates.new.fetch
    end
  end
end

desc "Load all data: fixtures, legislatures, districs, committess, people(including their addresses, photos), bills, mentions"
namespace :load do
  task :all  => :environment do
    # We don't load fixtures here anymore-- we load them earlier so we can use them to fetch the right districts and bills.

    puts "\n---------- Loading legislatures and districts"
    Rake::Task['load:legislatures'].execute
    Rake::Task['load:boundaries'].invoke
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
    OpenGov::Ratings.new.import_categories
  end

  namespace :fixtures do
    desc "Load fixtures for dev / testing"
    task :test => :environment do
      Fixtures.reset_cache
      fixtures_folder = File.join(Rails.root, 'spec', 'fixtures')
      fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
      Fixtures.create_fixtures(fixtures_folder, fixtures)
    end

    desc "Load fixtures for full production/staging import"
    task :seed => :environment do
      Dir.chdir(Rails.root)
      Fixtures.create_fixtures('lib/tasks/fixtures', 'legislatures')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'chambers')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'states')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'sessions')
      Fixtures.create_fixtures('lib/tasks/fixtures', 'tags')
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
      state ? OpenGov::Legislatures.new.import_state(state) : OpenGov::Legislatures.new.import
    end
  end

  desc "Fetch and load mentions"
  task :mentions => :environment do
    OpenGov::Mentions.new.import
  end

  desc "Load bills from Open State data"
  task :bills => :environment do
    puts "Loading bills from Open State data"
    with_states do |state|
      if state
        OpenGov::Bills.new.import_state(state)
        OpenGov::KeyVotes.new.import_state(state)
      else
        OpenGov::Bills.new.import
        OpenGov::KeyVotes.new.import
      end
    end
  end

  desc "Match key votes from Votesmart"
  task :keyvotes => :environment do
    with_states do |state|
      if state
        OpenGov::KeyVotes.new.import_state(state)
      else
        OpenGov::KeyVotes.new.import
      end
    end
  end

  desc "Fetch and load committees from OpenStates"
  task :committees => :environment do
    with_states do |state|
      state ? OpenGov::Committees.new.import_state(state) : OpenGov::Committees.new.import
    end 
  end

  desc "Fetch and load industries from FollowTheMoney"
  task :industries => :environment do
    OpenGov::Industries.new.import
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
      state ? OpenGov::People.new.import_state(state) : OpenGov::People.new.import
      Dir.chdir(Rails.root)
      GovTrackImporter.new.import!

      # These methods all act on all people with votesmart ids
      Dir.chdir(Rails.root)
      state ? OpenGov::Addresses.new.import_state(state) : OpenGov::Addresses.new.import

      puts "---------- Importing bios from Wikipedia."
      state ? OpenGov::Bios.new.import_state(state) : OpenGov::Bios.new.import
    end
  end

  desc "Fetch and load people ratings VoteSmart"
  task :ratings => :environment do
    OpenGov::Ratings.new.import
  end

  desc "Import Census Bureau boundaries"
  task :boundaries => :environment do
    OpenGov::Boundaries.new.import_districts
    class_refresh("District")

    OpenGov::Boundaries.new.import_states
    class_refresh("StateBoundary")
  end

end

