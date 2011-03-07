desc "Sync OpenGovernment data"
task :sync => :environment do

end

namespace :sync do
  desc "Open States API data"

  task :openstates => :environment do
    with_states do |state|
      if state
        # This is always a remote call.
        OpenGov::Legislatures.new.import_state(state)

        OpenGov::People.new.import_state(state, :remote => true)
        OpenGov::Committees.new.import_state(state, :remote => true)
        OpenGov::Bills.new.import_state(state, :remote => true)
      else
        # In case there are new legislative sessions or subsessions.
        # This is always a remote call.
        OpenGov::Legislatures.new.import

        # Updates to people and committees
        OpenGov::People.new.import(:remote => true)
        OpenGov::Committees.new.import(:remote => true)

        # Import any bills updated since last import
        OpenGov::Bills.new.import(:remote => true)
      end
    end

  end

  desc "Fetch votesmart photos for missing candidates"
  task :photos => :environment do
    OpenGov::Photos.new.import
  end

end
