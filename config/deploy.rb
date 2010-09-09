#
# This uses the capistrano multistage extension (gem install capistrano-ext) to deploy
# to multiple environments.
#
# Use cap deploy to deploy to production; cap staging deploy to deploy to dev.
#
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :stages, %w(staging production)
set :default_stage, "staging"
set :user, "cappy"
set :runner, "cappy"

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
    run "cp #{deploy_to}/#{shared_dir}/config/database.yml #{current_release}/config/database.yml"
    run "cp #{deploy_to}/#{shared_dir}/config/api_keys.yml #{current_release}/config/api_keys.yml"
    run "ln -s #{deploy_to}/#{shared_dir}/robots.txt #{current_release}/public/robots.txt"
    run "ln -s #{deploy_to}/#{shared_dir}/data #{current_release}/data"
#    sudo "chgrp -R apache #{current_release}"
    link_sphinx
  end

  task :link_sphinx do
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
