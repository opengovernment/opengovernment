module OpenGov
  class Bills < Resources
    def initialize
      # Cache all of the ids of people so we don't have to keep looking them up.
      @people = {}

      Person.all(:conditions => "openstates_id is not null").each do |p|
        @people[p.openstates_id] = p.id
      end
    end

    # TODO: The :remote => false option only applies to the intial import.
    # after that, we always want to use import_state(state)
    def import(options = {})
      State.loadable.each do |state|
        import_state(state, options)
      end
    end

    def import_state(state, options = {})
      if options[:remote]
        import_remote(state)
      else
        state_dir = File.join(Settings.openstates_dir, "bills", state.abbrev.downcase)

        unless File.exists?(state_dir)
          puts "Local Open State API data for #{state.name} is missing."
          return import_state(state, :remote => true)
        end

        puts "\nLoading local Open State data for #{state.name}."
        state.sessions.each do |session|
          [GovKit::OpenStates::CHAMBER_LOWER, GovKit::OpenStates::CHAMBER_UPPER].each do |house|
            bills_dir = File.join(state_dir, session.name, house)
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
                puts "Failed to import bill #{file}: #{e}"
                puts e.backtrace
              end
            end
          end
        end
      end
    end

    def import_remote(state)
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

    def import_bill(bill, state, options)
      @sync_date = Time.now
      
      Bill.transaction do
        # A bill number alone does not identify a bill; we also need a session ID.
        session = state.legislature.sessions.find_by_name(bill.session)

        @bill = Bill.find_or_initialize_by_session_id_and_bill_number(session.id, bill[:bill_id])

        # Identical bill contents; skip!
        if !@bill.new_record? && (options[:remote] && @bill.openstates_md5sum == bill.to_md5)
          return
        end

        @bill.title = bill.title
        @bill.session_id = session.id
        @bill.alternate_titles = bill[:alternate_titles]

        @bill.openstates_updated_at = bill[:updated_at]
        @bill.openstates_md5sum = bill.to_md5 if options[:remote]

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

        # There is no unique data on these tables that we can key off of, so we're
        # deleting them.
        @bill.delete_associated_nonuniques unless @bill.new_record?

        unless @bill.new_record?
          @bill.actions.delete_all
          @bill.sponsorships.delete_all
          @bill.citations.destroy_all
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
              :url => source.url
            )
          end
        end

        import_queue = []

        bill.actions.each do |action|
          action_date = Date.valid_date!(action.date)
          
          @bill.first_action_at ||= action_date
          @bill.first_action_at = action_date if @bill.first_action_at > action_date

          @bill.last_action_at ||= action_date
          @bill.last_action_at = action_date if @bill.last_action_at < action_date

          import_queue << Action.new(
            :bill_id => @bill.id,
            :actor => action.actor,
            :action => action.action,
            :kind_one => action[:type].try(:first),
            :kind_two => action[:type].try(:second),
            :kind_three => action[:type].try(:third),
            :action_number => action[:action_number],
            :date => action_date,
            :updated_at => @sync_date
          )
        end

        Action.import(import_queue) unless import_queue.blank?

        # Save the first & last action dates
        @bill.save

        # Bill documents & versions are very processor intensive to build for
        # the document viewer, so we avoid deleting and reimporting them if we can
        # help it.

        bill.versions.each do |version|
          # Versions aren't really useful without a URL, so we're
          # not importing them.
          unless version[:url].blank?
            BillDocument.find_or_create_by_bill_id_and_url(@bill.id, version[:url]) do |v|
              v.name = version[:name],
              v.published_at = Date.valid_date!(version[:'+date']),
              v.document_type = 'version',
              v.updated_at = @sync_date
              v.save
            end
          end
        end

        bill.documents.each do |doc|
          # Documents aren't really useful without a URL, so we're
          # not importing them.
          unless doc[:url].blank?
            BillDocument.find_or_create_by_bill_id_and_url(@bill.id, doc[:url]) do |document|
              document.name = doc[:name]
              document.published_at = Date.valid_date!(doc[:'+date'])
              document.document_type = 'document'
              document.updated_at = @sync_date
              document.save
            end
          end
        end

        # Delete any versions or documents that we didn't just touch.
        @bill.versions.where(['updated_at <> ?', @sync_date]).destroy_all
        @bill.documents.where(['updated_at <> ?', @sync_date]).destroy_all

        # Same deal as with actions, above
        import_queue = []

        bill.sponsors.each do |sponsor|
          import_queue << BillSponsorship.new(
            :sponsor_id => sponsor.leg_id.blank? ? nil : @people[sponsor.leg_id],
            :sponsor_name => sponsor[:name],
            :kind => sponsor[:type],
            :bill_id => @bill.id,
            :updated_at => @sync_date
          )
        end
        BillSponsorship.import(import_queue) unless import_queue.blank?

        if bill[:subjects] || bill[:"+subjects"]
          subjects = bill[:subjects] || bill[:"+subjects"]
          subjects.each do |subject|
            s = Subject.find_or_create_by_name(subject.strip)
            @bill.subjects << s
          end
        end

        # In case votes were deleted upstream, delete all existing
        # votes that aren't part of the new record.
        unless @bill.votes.empty?
          current_vote_ids = @bill.votes.collect {|v| v.openstates_id }
          importing_vote_ids = bill.votes.collect {|v| v.vote_id }
          removed_vote_ids = current_vote_ids - importing_vote_ids
          Vote.destroy_all(:openstates_id => removed_vote_ids) unless removed_vote_ids.empty?
        end

        bill.votes.each do |vote|
          v = Vote.find_or_create_by_openstates_id(vote.vote_id)

          v.attributes = {
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
          }

          # We will rebuild all roll calls.
          v.roll_calls.delete_all unless v.new_record?

          # Save the vote
          @bill.votes << v

          # Now attach roll calls.
          import_queue = []

          ['yes', 'no', 'other'].each do |vote_type|
            vote["#{vote_type}_votes"] && vote["#{vote_type}_votes"].each do |rcall|
              import_queue << RollCall.new(:vote_id => v.id, :vote_type => vote_type, :person_id => @people[rcall.leg_id.to_s]) if rcall.leg_id
            end
          end

          RollCall.import(import_queue) unless import_queue.empty?
        end

      end # transaction
    end # import_bill
  end # Class
end # module
