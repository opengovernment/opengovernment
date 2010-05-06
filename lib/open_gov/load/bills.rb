module OpenGov::Load::Bills
  def self.import!
    State.loadable.each do |state|
      import_one(state)
    end
  end

  def self.import_one(state)
    puts "Importing bills for #{state.name} \n"
    bills = Govkit::FiftyStates::Bill.latest("2010-04-20", state.abbrev.downcase)

    if bills.empty?
      puts "No bills found \n"
    else
      bills.each do |bill|
        puts "Importing #{bill.bill_id}.."

        @bill = Bill.find_or_create_by_legislature_bill_id(bill.bill_id)
        @bill.title = bill.title
        @bill.fiftystates_id = bill.id
        @bill.state = state
        @bill.chamber = state.legislature.instance_eval("#{bill.chamber}_chamber")
        @bill.session = state.legislature.sessions.find_by_name(bill.session)

        bill.actions.each do |action|
          a = @bill.actions.find_or_create_by_actor(
            :actor => action.actor,
            :action => action.action,
            :date => valid_date!(action.date)
          )
        end

        bill.versions.each do |version|
          v = @bill.versions.find_or_create_by_name(
            :name => version.name,
            :url => version.url
          )
        end

        bill.sponsors.each do |sponsor|
          s = Person.find_by_fiftystates_id(sponsor.leg_id)
          if @bill.sponsors.include?(s)
            next
          else
            @bill.sponsors << s
          end
        end

        bill.votes.each do |vote|
          v = @bill.votes.find_or_create_by_legislature_vote_id(
            :legislature_vote_id => vote.vote_id.to_s,
            :yes_count => vote.yes_count,
            :no_count => vote.no_count,
            :other_count => vote.other_count,
            :passed => vote.passed,
            :date => valid_date!(vote.date),
            :motion => vote.motion,
            :chamber => state.legislature.instance_eval("#{vote.chamber}_chamber")
          )

          fiftystates_vote = Govkit::FiftyStates::Vote.find(vote.vote_id)

          fiftystates_vote.roll.each do |roll|
            r = v.rolls.find_or_create_by_leg_id(
              :leg_id => roll.leg_id,
              :vote_type => roll['type']
            )
          end
        end

        @bill.save
        puts "done\n"
      end
    end
  end

  def self.valid_date!(date)
    Date.parse(date) rescue nil
  end
end
