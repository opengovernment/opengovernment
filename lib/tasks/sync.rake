desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Open States API data"
  task :openstates => :environment do
    OpenGov::Fetch::States.process
  end

  desc "Fetch bill full text and associated documents"
  task :bill_texts => :environment do
    OpenGov::BillTexts.sync!
  end

end
