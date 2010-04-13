#
# This uses the capistrano multistage extension (gem install capistrano-ext) to deploy
# to multiple environments.
#
# Use cap deploy to deploy to production; cap staging deploy to deploy to dev.
#
set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

#
# These may be overridden by deploy/staging.rb:
#
set :application, "opengovernment"
set :deploy_to, "/u/apps/opengovernment"
set :rake, "/opt/rubye/bin/rake"

default_run_options[:pty] = true
set :repository,  "git://github.com/opengovernment/opengovernment.git"
set :branch, "master"
set :scm, :git
set :git_shallow_clone, 1

default_run_options[:pty] = true
set :use_sudo, true

namespace :deploy do
  desc "Link the images"
  task :link_images do
    run "cp #{deploy_to}/#{shared_dir}/database.yml #{current_release}/config/database.yml"
    run "cp #{deploy_to}/#{shared_dir}/api_keys.yml #{current_release}/config/api_keys.yml"
    run "cp #{deploy_to}/#{shared_dir}/gmaps_api_key.yml #{current_release}/config/gmaps_api_key.yml"
#    run "ln -s #{deploy_to}/#{shared_dir}/files/synch_s3_asset_host.yml #{current_release}/config/"
    sudo "chown -R mongrel:admins #{current_release}"
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
    sudo "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

# Deploy hooks...

#
# Delete all but the last 4 releases:
#
set :keep_releases, 4
after "deploy:update", "deploy:cleanup"
#after "deploy:update_code", "deploy:link_images"
#after "deploy:update_code", "deploy:jammit"
