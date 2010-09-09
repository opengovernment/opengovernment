$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
set :rvm_ruby_string, 'ruby-1.9.2'

set :rails_env, "production"
set :branch, "production"
set :deploy_to, "/web/opengovernment.org"

role :web, "bearclaw.opengovernment.org"
role :app, "bearclaw.opengovernment.org"
role :db,  "bearclaw.opengovernment.org", :primary => true
