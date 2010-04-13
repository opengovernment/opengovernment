Scenario: Available States
   In order to manage the launches of OpenGovernment states
   As an administrator
   I want to see and modify an accurate list of current, pending, and unsupported states in OpenGovernment

   Scenario: Show a supported state
      Given a state named "Applefornia" with launch date of "1.day.ago"
      When I go to the admin list of states
      Then I should see "Applefornia" within "#status_supported"

   Scenario: Show an unsupported state
      Given a state named "Microsoftington"
      When I go to the admin list of states
      Then I should see "Microsoftington" within "#status_unsupported"

   Scenario: Show a pending state
      Given a state named "Zappostucky" with launch date of "1.day.from_now"
      When I go to the admin list of states
      Then I should see "Zappostucky" within "#status_pending"
