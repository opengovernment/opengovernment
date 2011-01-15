desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Open States API data"

  task :openstates => :environment do
    # In case there are new legislative sessions or subsessions.
    # This is always a remote call.
    OpenGov::Legislatures.import!

    # Updates to people and committees
    OpenGov::People.import!(:remote => true)
    OpenGov::Committees.import!(:remote => true)

    # Import any bills updated since last import
    OpenGov::Bills.import!(:remote => true)
  end

  desc "Fetch votesmart photos for missing candidates"
  task :photos => :environment do
    OpenGov::Photos.import!
  end

end
