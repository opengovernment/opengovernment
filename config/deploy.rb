#
# This uses the capistrano multistage extension (gem install capistrano-ext) to deploy
# to multiple environments.
#
# Use cap deploy to deploy to production; cap staging deploy to deploy to dev.
#
set :stages, %w(staging production)
set :default_stage, "staging"
set :user, "cappy"
set :runner, "cappy"

require 'capistrano/ext/multistage'

#
# These may be overridden by deploy/staging.rb:
#
set :application, "opengovernment"
set :deploy_to, "/u/apps/opengovernment"
set :rake, "/opt/rubye/bin/rake"

default_run_options[:pty] = true
set :repository, "git://github.com/opengovernment/opengovernment.git"
set :branch, "master"
set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

namespace :deploy do
  desc "Link the shared/ files"
  task :link_shared do
    run "cp #{deploy_to}/#{shared_dir}/database.yml #{current_release}/config/database.yml"
    run "cp #{deploy_to}/#{shared_dir}/api_keys.yml #{current_release}/config/api_keys.yml"
    run "ln -s #{deploy_to}/#{shared_dir}/data #{current_release}/data"
#    run "ln -s #{deploy_to}/#{shared_dir}/files/synch_s3_asset_host.yml #{current_release}/config/"
    sudo "chgrp -R apache #{current_release}"
    run "ln -s #{shared_path}/db/sphinx #{current_release}/db/sphinx"
  end

  desc "Compile CSS & JS for public/assets/ (see assets.yml)"
  task :jammit do
    run "cd #{current_release}; /opt/rubye/bin/jammit"

    # .gz filenames do not work in safari; we need to rename these files.
    # .cssjz and .jsjz are special extensions recognized by the S3 syncher so it
    # will do the right thing with respect to the Content-Type and Content-Encoding headers.
    run "cd #{current_release}/public/assets; for f in *.css.gz; do mv $f `basename $f .css.gz`.cssgz; done; for f in *.js.gz; do mv $f `basename $f .js.gz`.jsgz; done"
  end

  desc "Restart Passenger"
  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

namespace :bundler do
  %w(install update uninstall).each do |cmd|
    task cmd, :except => {:no_release => true} do
      opts = cmd == 'uninstall' ? '--all' : '--source=http://gemcutter.org --no-rdoc --no-ri'
      run("sudo gem #{cmd} bundler #{opts}")
    end
  end

  task :symlink_vendor do
    run %Q{ rm -fr   #{release_path}/vendor/bundler_gems}
    run %Q{ mkdir -p #{shared_path}/bundler_gems}
    run %Q{ ln -nfs  #{shared_path}/bundler_gems #{release_path}/vendor/bundler_gems}
  end

  task :bundle_new_release do
    bundler.symlink_vendor
    run("cd #{release_path} && bundle install vendor/bundler_gems && bundle lock")
    sudo "chmod g+w -R #{release_path}/.bundle #{release_path}/tmp"
  end
end

namespace :sphinx do
  desc "Generate the Sphinx configuration file"
  task :configure do
    rake "thinking_sphinx:configure"
  end

  desc "Index data"
  task :index do
    rake "thinking_sphinx:index"
  end

  desc "Start the Sphinx daemon"
  task :start do
    configure
    rake "thinking_sphinx:start"
  end

  desc "Stop the Sphinx daemon"
  task :stop do
    configure
    rake "thinking_sphinx:stop"
  end

  desc "Stop and then start the Sphinx daemon"
  task :restart do
    stop
    start
  end

  desc "Stop, re-index and then start the Sphinx daemon"
  task :rebuild do
    stop
    index
    start
  end

  desc "Add the shared folder for sphinx files for the environment"
  task :shared_sphinx_folder, :roles => :web do
    run "mkdir -p #{shared_path}/db/sphinx/#{rails_env}"
  end

  def rake(*tasks)
    rails_env = fetch(:rails_env, "production")
    rake = fetch(:rake, "rake")
    tasks.each do |t|
      run "if [ -d #{release_path} ]; then cd #{release_path}; else cd #{current_path}; fi; #{rake} RAILS_ENV=#{rails_env} #{t}"
    end
  end
end

after 'deploy:update_code', 'bundler:bundle_new_release'

# Deploy hooks...

#
# Delete all but the last 4 releases:
#
set :keep_releases, 4
after "deploy:cleanup", "sphinx:shared_sphinx_folder"
after "deploy:update", "deploy:cleanup"
after "deploy:update_code", "deploy:link_shared"
after "deploy:cleanup", "sphinx:rebuild"
#after "deploy:update_code", "deploy:jammit"
