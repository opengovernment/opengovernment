require File.dirname(__FILE__) + "/rake_extensions"

desc "Prepare the database: load schema, load sql seeds, load postgis tables"
namespace :db do

#  namespace :test do
    # TODO: This is a big tricksy. I'd rather find a smoother way to get the CI
    # server not to run db:test:prepare when trying to run tests.
#    remove_task :"db:test:prepare"
    
#    task :prepare => ["db:reset"]
#  end

  desc "Create database w/postgis, full schema, and additional DDL"
  task :prepare_without_fixtures do
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

  desc "Prepare the database: load postgis, schema, DDL."
  task :prepare do
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
          possible_postgis_dirs = [
            Dir.glob(File.join($1, 'contrib', 'postgis-*')).last,
            File.join($1, 'contrib'),
            '/usr/local/share/postgis'
          ].compact

          postgis_dir = possible_postgis_dirs.find { |dir| dir if File.exists?(File.join(dir, 'postgis.sql')) }

          raise "Could not find PostGIS" if postgis_dir.blank?
        else
          raise "Could not find pg_config; please install PostgreSQL and PostGIS"
        end
        puts "Found PostGIS in #{postgis_dir}"

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
