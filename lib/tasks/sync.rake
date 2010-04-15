desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Fifty States API data"
  task :fiftystates => :environment do
    OpenGov::Fetch::States.process
  end
end
