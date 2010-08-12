set :deploy_to, "/u/apps/og-staging"
set :rails_env, "staging"
set :branch, "master"
role :web, "dev.opencongress.org"
role :app, "dev.opencongress.org"
role :db,  "dev.opencongress.org", :primary => true
set :environment_database, 'og_staging'
set :environment_dbhost, 'localhost'
set :staging_database, 'og_staging'
set :staging_dbhost, 'localhost'

namespace :deploy do
  desc "Hook up staging symlinks"
  task :symlinks do
    run "ln -s #{current_release}/public/robots.txt.staging #{current_release}/public/robots.txt"
    run "mv #{current_release}/vendor/plugins/acts_as_solr/solr #{current_release}/vendor/plugins/acts_as_solr/solr-notused"
    run "ln -s #{deploy_to}/#{shared_dir}/solr #{current_release}/vendor/plugins/acts_as_solr/solr"
  end
end

#after "deploy:update_code", "deploy:symlinks"

