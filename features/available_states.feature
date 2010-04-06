Scenario: Available States
   In order to see if OpenGovernment is in my state
   As a follower of politics
   I want to see an accurate list of current, pending, and unsupported states in OpenGovernment

   Scenario: Show a supported state
      Given a state named "California" with launch date of "1.day.ago"
      When I go to the list of states
      Then I should see "California" within "#status_supported"

   Scenario: Show an unsupported state
      Given a state named "Hawaii"
      When I go to the list of states
      Then I should see "Hawaii" within "#status_unsupported"

   Scenario: Show a pending state
      Given a state named "Maryland" with launch date of "1.day.from_now"
      When I go to the list of states
      Then I should see "Maryland" within "#status_pending"
