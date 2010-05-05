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
          a = @bill.actions.find_or_create_by_actor(action.actor)
          a.action = action.action
          a.date = Date.parse(action.date) rescue nil
        end

        bill.versions.each do |version|
          v = @bill.versions.find_or_create_by_name(version.name)
          v.url = version.url
        end

        bill.sponsors.each do |sponsor|
          s = Person.find_by_fiftystates_id(sponsor.leg_id)
          if @bill.sponsors.include?(s)
            next
          else
            @bill.sponsors << s
          end
        end

        @bill.save
        puts "done\n"
      end
    end
  end
end
