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
  desc "Link the shared/ files"
  task :link_shared do
    run "cp #{deploy_to}/#{shared_dir}/database.yml #{current_release}/config/database.yml"
    run "cp #{deploy_to}/#{shared_dir}/api_keys.yml #{current_release}/config/api_keys.yml"
    run "cp #{deploy_to}/#{shared_dir}/gmaps_api_key.yml #{current_release}/config/gmaps_api_key.yml"
#    run "ln -s #{deploy_to}/#{shared_dir}/files/synch_s3_asset_host.yml #{current_release}/config/"
    sudo "chgrp -R admins #{current_release}"
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
    sudo "chgrp admins #{deploy_to}/current"
    sudo "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

namespace :bundler do  
  %w(install update uninstall).each do |cmd|  
    task cmd, :except => { :no_release => true }  do  
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
after 'deploy:update_code', 'bundler:bundle_new_release'

# Deploy hooks...

#
# Delete all but the last 4 releases:
#
set :keep_releases, 4
after "deploy:update", "deploy:cleanup"
after "deploy:update_code", "deploy:link_shared"
#after "deploy:update_code", "deploy:jammit"
