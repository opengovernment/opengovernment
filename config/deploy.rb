#
# This uses the capistrano multistage extension (gem install capistrano-ext) to deploy
# to multiple environments.
#
# Use cap deploy to deploy to production; cap staging deploy to deploy to dev.
#
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

require 'delayed/recipes'

set :stages, %w(staging production)
set :default_stage, 'production'
set :user, 'cappy'
set :runner, 'cappy'
set :application, 'opengovernment'

default_run_options[:pty] = true
set :repository, 'git://github.com/opengovernment/opengovernment.git'
set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

namespace :deploy do
  desc 'Link the shared/ files'
  task :link_shared do
    run "ln -s #{deploy_to}/#{shared_dir}/config/database.yml #{current_release}/config/database.yml"
    run "ln -s #{deploy_to}/#{shared_dir}/config/api_keys.yml #{current_release}/config/api_keys.yml"
    run "ln -s #{deploy_to}/#{shared_dir}/robots.txt #{current_release}/public/robots.txt"
    run "ln -s #{deploy_to}/#{shared_dir}/data #{current_release}/data"
#    sudo "chgrp -R apache #{current_release}"
    link_sphinx
  end

  task :link_sphinx do
    run "ln -s #{shared_path}/db/sphinx #{current_release}/db/sphinx"
  end

  desc 'Restart Passenger'
  task :restart do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  desc 'Compile CSS & JS for public/assets/ (see assets.yml)'
  task :jammit do
    run "cd #{current_release}; bundle exec jammit"
    
    # For Apache content negotiation with Multiviews, we need to rename .css files to .css.css and .js files to .js.js.
    # They will live alongside .css.gz and .js.gz files and the appropriate file will be served based on Accept-Encoding header.
    run "cd #{current_release}/public/assets; for f in *.css; do mv $f `basename $f .css`.css.css; done; for f in *.js; do mv $f `basename $f .js`.js.js; done"
  end
end

# Deploy hooks...


#
# Delete all but the last 4 releases:
#
set :keep_releases, 4
after 'deploy:update', 'deploy:cleanup'
after 'deploy:update_code', 'deploy:link_shared'
after 'deploy:update_code', 'deploy:jammit'
after 'deploy:update_code', 'delayed_job:restart'
after 'deploy:cleanup', 'sphinx:rebuild'
after 'deploy:cleanup', 'sphinx:shared_sphinx_folder'
