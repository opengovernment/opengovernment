# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'

# TODO: This is a temp. fix for Rake 0.9.0 bug "undefined method `task' for #<OpenGov::Application:0xb5d04548>"
# Please remove later.
module ::OpenGov
  class Application
    include Rake::DSL
  end
end

module ::RakeFileUtils
  extend Rake::FileUtilsExt
end

OpenGov::Application.load_tasks

