module OpenGov
  class Bills < Resources
    VOTES_DIR = File.join(Settings.openstates_dir, "api", "votes")

    @@people = {}

    def self.build_people_hash
      # Cache all of the ids of people so we don't have to keep looking them up.
      if @@people.size == 0
        Person.all(:conditions => "openstates_id is not null").each do |p|
          @@people[p.openstates_id] = p.id
        end
      end
    end

    # TODO: The :remote => false option only applies to the intial import.
    # after that, we always want to use import_state(state)
    def self.import!(options = {})
      State.loadable.each do |state|
        import_state(state, options)
      end
    end

    def self.import_state(state, options = {})
      build_people_hash

      if options[:remote]
        import_remote(state)
      else
        state_dir = File.join(Settings.openstates_dir, "api", state.abbrev.downcase)

        unless File.exists?(state_dir)
          puts "Local Open State API data for #{state.name} is missing."
          return import_state(state, :remote => true)
        end

        puts "\nLoading local Open State data for #{state.name}."
        state.sessions.each do |session|
          [GovKit::OpenStates::CHAMBER_LOWER, GovKit::OpenStates::CHAMBER_UPPER].each do |house|
            bills_dir = File.join(state_dir, session.name, house, "bills")
            all_bills = File.join(bills_dir, "*")
            Dir.glob(all_bills).each_with_index do |file, i|
              if i % 10 == 0
                print '.'
                $stdout.flush
              end

              begin
                bill = GovKit::OpenStates::Bill.parse(JSON.parse(File.read(file)))
                import_bill(bill, state, options)
              rescue ArgumentError => e
                puts "Failed to parse bill #{file}: #{e}"
              end
            end
          end
        end
      end
    end

    def self.import_remote(state)
      build_people_hash

      puts "\nUpdating Open State bill data for #{state.name} from remote API"

      if state.bills.count > 0
        latest_updated_date = Bill.where(:state_id => state.id).maximum(:openstates_updated_at).to_date

        begin
          bills = GovKit::OpenStates::Bill.latest(latest_updated_date, :state => state.abbrev.downcase)
        rescue GovKit::ResourceNotFound
          puts "No updates for #{state.name}."
          return
        end
      else
        puts "You have no existing bills to update. Please import an initial set of bills for this state."
        return
      end

      if bills.empty?
        puts "No bills found \n"
      else
        puts "Importing/updating #{bills.size} bills updated since #{latest_updated_date.to_s}"
        bills.each_with_index do |bill, i|
          if i % 10 == 0
            print '.'
            $stdout.flush
          end
          begin
            import_bill(GovKit::OpenStates::Bill.find(state.abbrev, bill[:session], bill[:bill_id], bill[:chamber]), state, {})
          rescue ArgumentError => e
            puts "Failed to parse bill #{bill[:bill_id]}: #{e}"
          end
        end
      end
    end

    def self.import_bill(bill, state, options)
      build_people_hash

      Bill.transaction do
        # A bill number alone does not identify a bill; we also need a session ID.
        session = state.legislature.sessions.find_by_name(bill.session)

        @bill = Bill.find_or_initialize_by_session_id_and_bill_number(session.id, bill[:bill_id])
        @bill.title = bill.title
        @bill.session_id = session.id
        @bill.alternate_titles = bill[:alternate_titles]
        @bill.openstates_updated_at = bill[:updated_at]

        # Exclude types 'bill'
        @bill_types = bill[:type] || []
        @bill_types.delete("bill")

        @bill.kind_one = @bill_types[0]
        @bill.kind_two = @bill_types[1]
        @bill.kind_three = @bill_types[2]
        if @bill_types.size > 3
          puts "Skipping bill types for #{bill[:bill_id]}: #{@bill_types[3..-1].join(', ')}."
        end

        @bill.state = state
        @bill.chamber = state.legislature.instance_eval("#{bill.chamber}_chamber")

        # There is no unique data on a bill's actions that we can key off of, so we
        # must delete and recreate them all each time.
        unless @bill.new_record?
          @bill.actions.delete_all
          @bill.sponsors.delete_all
          @bill.citations.destroy_all
          @bill.versions.destroy_all
          @bill.documents.destroy_all
          @bill.votes.destroy_all
          @bill.subjects.destroy_all
        end

        unless @bill.save!
          # The transaction has rolled back if we get to this point.
          puts "Skipping...#{@bill.errors.full_messages.join(',')}"
          return
        end

        if bill[:sources]
          bill.sources.each do |source|
            @bill.citations << Citation.new(
              :url => source.url,
              :retrieved => Date.valid_date!(source.retrieved)
            )
          end
        end

        bill.actions.each do |action|
          action_date = Date.valid_date!(action.date)
          
          @bill.first_action_at ||= action_date
          @bill.first_action_at = action_date if @bill.first_action_at > action_date

          @bill.last_action_at ||= action_date
          @bill.last_action_at = action_date if @bill.last_action_at < action_date

          @bill.actions << Action.new(
            :actor => action.actor,
            :action => action.action,
            :kind_one => action[:type].try(:first),
            :kind_two => action[:type].try(:second),
            :kind_three => action[:type].try(:third),
            :action_number => action[:action_number],
            :date => action_date
          )
        end

        # Save the first & last action dates
        @bill.save

        bill.versions.each do |version|
          @bill.versions << BillVersion.new(
            :name => version[:name],
            :url => version[:url]
          )
        end

        bill.documents.each do |doc|
          @bill.documents << BillDocument.new(
            :name => doc[:name],
            :url => doc[:url]
          )
        end

        # Same deal as with actions, above
        bill.sponsors.each do |sponsor|
          @bill.sponsorships << BillSponsorship.new(
            :sponsor_id => sponsor.leg_id.blank? ? nil : @@people[sponsor.leg_id],
            :sponsor_name => sponsor[:name],
            :kind => sponsor[:type]
          )
        end

        if bill[:subjects] || bill[:"+subjects"]
          subjects = bill[:subjects] || bill[:"+subjects"]
          subjects.each do |subject|
            s = Subject.find_or_create_by_name(subject.strip)
            @bill.subjects << s
          end
        end

        bill.votes.each do |vote|
          v = @bill.votes.create(
            :yes_count => vote.yes_count,
            :no_count => vote.no_count,
            :other_count => vote.other_count,
            :passed => vote.passed,
            :date => Date.valid_date!(vote.date),
            :motion => vote.motion,
            :kind => vote[:type],
            :chamber => state.legislature.instance_eval("#{vote.chamber}_chamber"),
            :committee_name => vote[:committee],
            :threshold => vote['+threshold'].try(:to_frac)
          )

          ['yes', 'no', 'other'].each do |vote_type|
            vote["#{vote_type}_votes"] && vote["#{vote_type}_votes"].each do |rcall|
              v.roll_calls.create(:vote_type => vote_type, :person_id => @@people[rcall.leg_id.to_s]) if rcall.leg_id
            end
          end
        end

      end # transaction
    end # import_bill
  end # Class
end # module
