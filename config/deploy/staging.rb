set :rake, "/opt/rubye/bin/rake"
set :deploy_to, "/u/apps/og-staging"
set :rails_env, "staging"
set :branch, "master"
role :web, "dev.opencongress.org"
role :app, "dev.opencongress.org"
role :db,  "dev.opencongress.org", :primary => true

set :staging_database, "og_production"
set :staging_dbhost,   "localhost"

set :environment_database, defer { staging_database }
set :environment_dbhost, defer { staging_dbhost }
