# This comes directly from the eycap gem!
# But we've modified it to import data using the postgis_restore script
# and to get the db user for db:dump.
namespace :db do
  task :backup_name, :roles => :db, :only => { :primary => true } do
    now = Time.now
    run "mkdir -p #{shared_path}/db_backups"
    backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
    set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
  end

  desc "Clone Production Database to Staging Database."
  task :clone_prod_to_staging, :roles => :db, :only => { :primary => true } do
    # This task currently runs only on traditional EY offerings.
    # You need to have both a production and staging environment defined in
    # your deploy.rb file.

    backup_name unless exists?(:backup_file)
    run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
    dump

    if @environment_info['adapter'] == 'mysql'
      run "gunzip < #{backup_file}.gz | mysql -u #{dbuser} -p -h #{staging_dbhost} #{staging_database}" do |ch, stream, out|
         ch.send_data "#{dbpass}\n" if out=~ /^Enter password:/
      end
    else
      run "gunzip < #{backup_file}.gz | psql -W -U #{dbuser} -h #{staging_dbhost} #{staging_database}" do |ch, stream, out|
         ch.send_data "#{dbpass}\n" if out=~ /^Password/
      end
    end
    run "rm -f #{backup_file}.gz"
  end
  
  desc "EYCAP OVERRIDE: Backup your MySQL or PostgreSQL database to shared_path+/db_backups"
  task :dump, :roles => :db, :only => {:primary => true} do
    backup_name unless exists?(:backup_file)
    on_rollback { run "rm -f #{backup_file}" }
    run("cat #{shared_path}/config/database.yml") { |channel, stream, data| @environment_info = YAML.load(data)[rails_env] }
    
    dbuser = @environment_info['username']
    dbpass = @environment_info['password']
    if @environment_info['adapter'] == 'mysql'
      dbhost = @environment_info['host']
      dbhost = environment_dbhost.sub('-master', '') + '-replica' if dbhost != 'localhost' # added for Solo offering, which uses localhost
      run "mysqldump --add-drop-table -u #{dbuser} -h #{dbhost} -p #{environment_database} | gzip -c > #{backup_file}.gz" do |ch, stream, out |
         ch.send_data "#{dbpass}\n" if out=~ /^Enter password:/
      end
    else
      run "pg_dump -W -Fc -U #{dbuser} -h #{environment_dbhost} #{environment_database} | gzip -c > #{backup_file}.gz" do |ch, stream, out |
         ch.send_data "#{dbpass}\n" if out=~ /^Password:/
      end
    end
  end

  task :restore, :roles => :db, :only => {:primary => true} do
    # Find PostGIS
    if `pg_config` =~ /SHAREDIR = (.*)/
      postgis_dir = Dir.glob(File.join($1, 'contrib', 'postgis-*')).last || File.join($1, 'contrib')
      raise "Could not find PostGIS" unless File.exists? postgis_dir
    else
      raise "Could not find pg_config; please install PostgreSQL and PostGIS #{POSTGIS_VERSION}"
    end

    development_info = YAML.load_file("config/database.yml")['development']

    input_file_gz = ENV.has_key?('SQLGZ') ? ENV['SQLGZ'] : "/tmp/#{application}.sql.gz"
    input_file_sql = File.join(File.dirname(input_file_gz), File.basename(input_file_gz, '.gz'))

    run_str = "gunzip #{input_file_gz} && PGHOST=#{development_info['host']} PGPORT=#{development_info['port']} PGUSER=#{development_info['username']} PGPASSWORD=#{development_info['password']} script/postgis_restore.pl #{postgis_dir}/postgis.sql #{development_info['database']} #{input_file_sql}"

    puts run_str

    %x!#{run_str}!
  end

  desc "EYCAP OVERRIDE: Sync your production database to your local workstation"
  task :clone_to_local, :roles => :db, :only => {:primary => true} do
    backup_name unless exists?(:backup_file)
    dump

    get "#{backup_file}.gz", "/tmp/#{application}.sql.gz"
    restore
    run "rm -f #{backup_file}.gz"
  end
end
0
