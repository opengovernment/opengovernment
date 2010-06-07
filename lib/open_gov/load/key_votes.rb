module OpenGov::Load::KeyVotes
  def self.import!(options = {})
    State.loadable.each do |state|
      import_one(state)
    end
  end

  # Import all key votes for a given State
  def self.import_one(state)
    # TODO: Figure out a better way to fetch the current session's bills
    bills = GovKit::VoteSmart::Bill.find_by_year_and_state(2009, state.abbrev)

    # TODO: Look into bills we're missing: "PN 188", "S Amdt anything", ""
    bills.bill.each do |bill|
      if og_bill = Bill.find_by_bill_number(bill.billNumber)
        og_bill.update_attributes!(
          :votesmart_id => bill.billId,
          :votesmart_key_vote => true
        )
      end
    end
  end
end
