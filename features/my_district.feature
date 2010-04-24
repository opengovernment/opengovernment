Feature: My District
   In order to find out who my representatives are
   As a follower of politics
   I want to see an accurate list of people who represent me on the state and federal level.

   Scenario: Find my district
   Given the usual test setup
   When I am on the homepage
   And I fill in "Address" with "3306 French Place, Austin, TX 78722"
   And I press "Find"
   Then I should see "District 25"
   And I should see "District 46"
   And I should see "District 14"

   Scenario: Find my state representatives
   And I should see "Kirk Watson" within "#state-upper"
   And I should see "Dawnna M. Dukes" within "#state-lower"

   Scenario: Find my Congressional representatives
   And I should see "John Cornyn" within "#us-upper"
   And I should see "Lloyd A. Doggett" within "#us-lower"
