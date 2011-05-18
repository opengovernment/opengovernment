$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"

set :application, "opengovernment"
set :rvm_ruby_string, 'ree@og'
set :rails_env, "production"
set :branch, "production"
set :deploy_to, "/web/opengovernment.org"

role :web, "bearclaw.in.opengovernment.org"
role :app, "bearclaw.in.opengovernment.org"
role :db,  "bearclaw.in.opengovernment.org", :primary => true

set :production_database, "og_production"
set :production_dbhost,   "localhost"

set :environment_database, defer { production_database }
set :environment_dbhost, defer { production_dbhost }

namespace :deploy do
  desc 'Clear the varnish cache'
  task :varnish do
    run "varnishadm -T 127.0.0.1:2000 url.purge ."
  end
end

# after 'deploy:cleanup', 'deploy:varnish'

set :whenever_command, "bundle exec whenever"
set :whenever_roles, :app
require 'whenever/capistrano'

