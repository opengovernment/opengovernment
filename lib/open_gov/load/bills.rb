module OpenGov::Load::Bills
  def self.import!
    State.loadable.each do |state|
      import_one(state)
    end
  end

  def self.import_one(state)
    puts "Importing bills for #{state.name} \n"
    bills = Govkit::FiftyStates::Bill.latest("2010-04-01", state.abbrev.downcase)

    if bills.empty?
      puts "No bills found \n"
    else
      bills.each do |bill|
        puts "Importing #{bill.bill_id}.."

        @bill = Bill.find_or_create_by_legislature_bill_id(bill.bill_id)
        @bill.title = bill.title
        @bill.fiftystates_id = bill.id
        @bill.state = state
#        @bill.chamber = state.legislature.instance_eval("#{bill.chamber}_chamber")
#        @bill.session =
#
#        bill.versions.each do |version|
#          @bill.versions.build()
#        end
#
#        bill.sponsors.each do |version|
#          @bill.sponsors.build()
#        end

        @bill.save
        puts "done\n"
      end
    end
  end
end
