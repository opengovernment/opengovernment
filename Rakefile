# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

begin
  require File.expand_path('../config/application', __FILE__)
  rescue Bundler::PathError=>e
    # Fall back on doing an unlocked resolve at runtime.
    if (!system("bundle install"))
        puts $?
  end
end
require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rails::Application.load_tasks
