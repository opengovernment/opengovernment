module OpenGov
  class KeyVotes < Resources
    def import(options = {})
      State.loadable.each do |state|
        import_state(state)
      end
    end

    # Import all key votes for a given State
    def import_state(state)  
      puts "Marking Votesmart Key Votes for #{state.name}"
      i = 0
      
      # Get all the years possible.
      # We're not getting session IDs here because we'll have to look
      # them up for each bill. The bills may, for example, be part of a special
      # session.
      Session.find_by_sql(['select distinct start_year as year from sessions where legislature_id = ?
            union select distinct end_year as year from sessions where legislature_id = ?',
          state.legislature.id, state.legislature.id]).collect {|s| s.year }.uniq.each do |year|

        begin
          # Assumption: the bills returned for a given year were introduced during that year.
          if bills = GovKit::VoteSmart::Bill.find_by_year_and_state(year, state.abbrev)
            [*bills.bill].each do |bill|
              og_session = bill_type = bill_number = nil

              Rails.logger.debug "Trying #{bill.billNumber}"
              case bill.billNumber
                when /(^[A-Z]{2,3})(x(\d+))?\s+(\d+)/ # SB 12, ABx3 22
                  if $3
                    # Special session! This is a tricky lookup, should be easier.
                    Rails.logger.debug "Looking for special session #{$3} (#{$1 + $4})"
                    bill_type = $1
                    bill_number = $4
                    og_sessions = state.legislature.sessions.for_year(year).select { |s| s.special_number == $3.to_i }
                  elsif $1 && $4
                    # Major session
                    Rails.logger.debug "Looking for major session (#{$1 + $4})"
                    bill_type = $1
                    bill_number = $4
                    og_sessions = state.legislature.sessions.for_year(year).select { |s| s.special_number.nil? }
                  end
              end

              if og_sessions && og_bill = Bill.where(:session_id => og_sessions).with_type_and_number(bill_type, bill_number).first
                Rails.logger.debug "Found a bill #{og_bill.bill_number} in session #{og_bill.session.name}"
                i += 1
                og_bill.update_attributes!(
                  :votesmart_id => bill.billId,
                  :votesmart_key_vote => true
                )
              else
                puts "Could not match Votesmart key vote for #{bill.billNumber} in year #{year}"
              end
            end

          end

        rescue GovKit::ResourceNotFound
          next
        end

      end

      puts "Matched #{i} bills in #{state.name}"
    end
  end
end
