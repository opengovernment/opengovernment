module OpenGov
  class KeyVotes < Resources
    include StateWise

    # Import all key votes for a given State
    def import_state(state, options = {})  
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


    puts "Now looking up bill actions to add highlight & synopsis text..."
    Bill.with_key_votes.for_state(state.id).each do |bill|
      vs_bill = GovKit::VoteSmart::Bill.find(bill.votesmart_id)

      vs_action_ids = vs_bill.actions.action.collect { |a| a.actionId }

      vs_action_ids.each do |vs_action_id|
        vs_action = GovKit::VoteSmart::BillAction.find(vs_action_id)

        if !vs_action.synopsis.blank? && !vs_action.highlight.blank?
          # OK, we have something worth inserting here.
          kv = KeyVote.find_or_initialize_by_votesmart_action_id(vs_action_id)

          kv.attributes = {
            :bill => bill,
            :votesmart_action_id => vs_action_id,
            :title => vs_action.title,
            :highlight => vs_action.highlight,
            :synopsis => vs_action.synopsis,
            :stage => vs_action.stage,
            :level => vs_action.level,
            :url => vs_action.attributes['generalInfo']['linkBack']
          }

          kv.save
        end
      end
    end

    end
  end
end
