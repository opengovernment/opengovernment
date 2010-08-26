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
        
        #begin
        #  parser = "#{state.name.gsub(/ /, '').classify}Parser".constantize
        #rescue NameError
        #  parser = nil
        #end
        
        # Get all the years possible.
        # We're not getting session IDs here because we'll have to look
        # them up for each bill. The bills may, for example, be part of a special
        # session.
        Session.find_by_sql(['select distinct start_year as year from sessions where legislature_id = ?
              union select distinct end_year as year from sessions where legislature_id = ?',
            state.legislature.id, state.legislature.id]).collect {|s| s.year }.uniq.each do |year|

          # Assumption: the bills returned for a given year were introduced during that year.
          if bills = GovKit::VoteSmart::Bill.find_by_year_and_state(year, state.abbrev)
            bills.bill.each do |bill|
              og_session = bill_type = bill_number = nil

              Rails.logger.debug "Trying #{bill.billNumber}"
              case bill.billNumber
                when /(^[A-Z]{2,3})(x(\d+))?\s+(\d+)/ # SB 12, ABx3 22
                  if $3
                    # Special session! This is a tricky lookup, should be easier.
                    Rails.logger.debug "Looking for special session #{$3} (#{$1 + $4})"
                    bill_type = $1
                    bill_number = $4
                    og_session = state.legislature.sessions.for_year(year).select { |s| s.special_number == $3.to_i }.first
                  elsif $1 && $4
                    # Major session
                    Rails.logger.debug "Looking for major session (#{$1 + $4})"
                    bill_type = $1
                    bill_number = $4
                    og_session = state.legislature.sessions.major.for_year(year).first                   
                  end
              end

              if og_session && og_bill = Bill.where(:session_id => og_session.id).with_type_and_number(bill_type, bill_number).first
                Rails.logger.debug "Found a bill #{og_bill.bill_number} in session #{og_session.name}"
                og_bill.update_attributes!(
                  :votesmart_id => bill.billId,
                  :votesmart_key_vote => true
                )
              else
                puts "Could not match Votesmart key vote for #{bill.billNumber} in year #{year}"
              end
            end

          end
        end

      end
    end
  end
end
