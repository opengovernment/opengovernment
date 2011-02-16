desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Open States API data"

  task :openstates => :environment do
    with_states do |state|
      if state
        # This is always a remote call.
        OpenGov::Legislatures.import_state(state)

        OpenGov::People.import_state(state, :remote => true)
        OpenGov::Committees.import_state(state, :remote => true)
        OpenGov::Bills.import_state(state, :remote => true)
      else
        # In case there are new legislative sessions or subsessions.
        # This is always a remote call.
        OpenGov::Legislatures.import!

        # Updates to people and committees
        OpenGov::People.import!(:remote => true)
        OpenGov::Committees.import!(:remote => true)

        # Import any bills updated since last import
        OpenGov::Bills.import!(:remote => true)
      end
    end

  end

  desc "Fetch votesmart photos for missing candidates"
  task :photos => :environment do
    OpenGov::Photos.import!
  end

end
