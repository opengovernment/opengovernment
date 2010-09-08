set :deploy_to, "/u/apps/og-staging"
set :rails_env, "staging"
set :branch, "master"
role :web, "dev.opencongress.org"
role :app, "dev.opencongress.org"
role :db,  "dev.opencongress.org", :primary => true

namespace :deploy do
  desc "Hook up staging symlinks"
  task :symlinks do
    run "ln -s #{current_release}/public/robots.txt.staging #{current_release}/public/robots.txt"
  end
end

after "deploy:update_code", "deploy:symlinks"

