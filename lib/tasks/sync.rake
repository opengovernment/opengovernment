desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Open States API data"
  task :openstates => :environment do
    OpenGov::Fetch::States.process
  end

  desc "Fetch votesmart photos for missing candidates"
  task :photos => :environment do
    OpenGov::Photos.import!
  end

end
