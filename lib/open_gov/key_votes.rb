module OpenGov
  class KeyVotes < Resources
    class << self
      def import!(options = {})
        State.loadable.each do |state|
          import_one(state)
        end
      end

      # Import all key votes for a given State
      def import_one(state)  
        puts "Marking Votesmart Key Votes for #{state.name}"
        
        # begin
        #   parser = "#{State.find_by_abbrev('NH').name.gsub(/ /, '').classify}Parser".constantize
        # rescue NameError
        #   parser = nil
        # end
        # 
        # # TODO: Figure out a better way to fetch the current session's bills
        # state.sessions.each do |sesssion|
        #   bills = GovKit::VoteSmart::Bill.find_by_year_and_state(session.start_year, state.abbrev)
        #   
        #   bills.bill.each do |bill|
        #     if og_bill = Bill.find_by_bill_number(parser.votesmart_bill_number_for(bill))
        #       og_bill.update_attributes!(
        #         :votesmart_id => bill.billId,
        #         :votesmart_key_vote => true
        #       )
        #     end
        #   end
        # end
      
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
  end
end
