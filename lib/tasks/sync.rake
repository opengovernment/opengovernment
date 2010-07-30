desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Open States API data"
  task :openstates => :environment do
    OpenGov::Fetch::States.process
  end
end
