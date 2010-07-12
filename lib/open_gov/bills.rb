module OpenGov
  class Bills < Resources
    VOTES_DIR = File.join(FIFTYSTATES_DIR, "api", "votes")

    class << self
      def fetch
        # TODO: This is temporary, as we figure out with Sunlight where these bills
        # will really come from.

        FileUtils.mkdir_p(FIFTYSTATES_DIR)
        Dir.chdir(FIFTYSTATES_DIR)

        fiftystates_fn = 'tx.zip'
        curl_ops = File.exists?(fiftystates_fn) ? "-z #{fiftystates_fn}" : ''

        puts "Downloading the bills for Texas"
        `curl #{curl_ops} -fO http://fiftystates-dev.sunlightlabs.com/data/tx.zip`
        `unzip -u #{fiftystates_fn}`
      end

      # TODO: The :remote => false option only applies to the intial import.
      # after that, we always want to use import_state(state)
      def import!(options = {})
        if options[:remote]
          State.loadable.each do |state|
            import_state(state)
          end
        else
          state_dir = File.join(FIFTYSTATES_DIR, "api", "tx")

          unless File.exists?(state_dir)
            puts "Local Fifty States data is missing; fetching remotely instead."
            import!(:remote => true)
          end

          # TODO: Lookup currently active session
          tx = State.find_by_abbrev('TX')
          [81, 811].each do |session|
            [GovKit::FiftyStates::CHAMBER_LOWER, GovKit::FiftyStates::CHAMBER_UPPER].each do |house|
              bills_dir = File.join(state_dir, session.to_s, house, "bills")
              all_bills = File.join(bills_dir, "*")
              Dir.glob(all_bills).each_with_index do |file, i|
                if i % 10 == 0
                  print '.'
                  $stdout.flush
                end
                
                bill = GovKit::FiftyStates::Bill.parse(JSON.parse(File.read(file)))
                import_bill(bill, tx, options)
              end
            end
          end
        end
      end

      def import_state(state)
        puts "Importing bills for #{state.name} \n"

        # TODO: This isn't quite right...
        bills = GovKit::FiftyStates::Bill.latest(Bill.maximum(:updated_at).to_date, state.abbrev.downcase)

        if bills.empty?
          puts "No bills found \n"
        else
          bills.each_with_index do |bill, i|
            if i % 10 == 0
              print '.'
              $stdout.flush
            end

            import_bill(bill, state, {})
          end
        end
      end

      def import_bill(bill, state, options)
        Bill.transaction do
          # A bill number alone does not identify a bill; we also need a session ID.
          session = state.legislature.sessions.find_by_name(bill.session)
          
          @bill = Bill.find_or_initialize_by_bill_number_and_session_id(bill.bill_id, session.id)
          @bill.title = bill.title
          @bill.fiftystates_id = bill["_id"]
          @bill.state = state
          @bill.chamber = state.legislature.instance_eval("#{bill.chamber}_chamber")

          # There is no unique data on a bill's actions that we can key off of, so we
          # must delete and recreate them all each time.
          if @bill.id
            @bill.actions.delete_all
            @bill.sponsors.delete_all
            @bill.versions.delete_all
            @bill.votes.destroy_all
          end

          bill.actions.each do |action|
            @bill.actions << Action.new(
              :actor => action.actor,
              :action => action.action,
              :date => valid_date!(action.date))
          end

          bill.versions.each do |version|
            v = @bill.versions << Version.new(
              :name => version.name,
              :url => version.url)
          end

          # Same deal as with actions, above
          bill.sponsors.each do |sponsor|
            Sponsorship.create(
              :bill => @bill,
              :sponsor => Person.find_by_fiftystates_id(sponsor.leg_id.to_s),
              :kind => sponsor[:type]
            )
          end

          bill.votes.each do |vote|
            v = @bill.votes.create (
              :yes_count => vote.yes_count,
              :no_count => vote.no_count,
              :other_count => vote.other_count,
              :passed => vote.passed,
              :date => valid_date!(vote.date),
              :motion => vote.motion,
              :chamber => state.legislature.instance_eval("#{vote.chamber}_chamber")
            )
                        
            vote["yes_votes"] && vote["yes_votes"].each do |rcall|
              v.roll_calls.create(:vote_type => 'yes', :person => Person.find_by_fiftystates_id(rcall.leg_id.to_s))
            end

            vote["no_votes"] && vote["no_votes"].each do |rcall|
              v.roll_calls.create(:vote_type => 'no', :person => Person.find_by_fiftystates_id(rcall.leg_id.to_s))
            end

            vote["other_votes"] && vote["other_votes"].each do |rcall|
              v.roll_calls.create(:vote_type => 'other', :person => Person.find_by_fiftystates_id(rcall.leg_id.to_s))
            end
          end

          unless @bill.save!
            puts "Skipping...#{@bill.errors.full_messages.join(',')}"
          end
        end # transaction
      end
    end
  end
end
