Feature: My District
   In order to find out who my representatives are
   As a follower of politics
   I want to see an accurate list of people who represent me on the state and federal level.
   
   Scenario: Find my district
   Given the usual test setup
   When I am on the homepage
   And I fill in "Address" with "3306 French Place, Austin, TX 78722"
   And I press "Find"
   Then I should see "Your representatives"
   And I should see "District 25" under "Congressional"
   And I should see "District 46" under "State Legislature"
   And I should see "District 14" under "State Senate"

   Scenario: Find my representatives
   And I should see "Kirk Watson" under "State Senate"
   And I should see "Dawnna M. Dukes" under "State Legislature"
   And I should see "John Cornyn" under "U.S. Senate"
   And I should see "Lloyd A. Doggett" under "U.S. House"
