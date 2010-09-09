set :branch, "production"

role :web, "bearclaw.opengovernment.org"
role :app, "bearclaw.opengovernment.org"
role :db,  "bearclaw.opengovernment.org", :primary => true
