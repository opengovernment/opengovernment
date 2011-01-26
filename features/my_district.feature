Feature: My District
   In order to find out who my representatives are
   As a follower of politics
   I want to see an accurate list of people who represent me on the state and federal level.

  @uses_geocoder
  Scenario: Find my district
    When I am on the homepage
       # The label is unwieldy, so we have to use the input ID.
     And I fill in "q" with "3306 French Place, Austin, TX 78722"
     And I press "Find"

       # state representatives
    Then I should see "Kirk Watson"
     And I should see "District 14"
     And I should see "Dawnna Dukes"
     And I should see "District 46"

       # Congressional representatives
     And I should see "John Cornyn"
     And I should see "Kay Hutchison"
     And I should see "Lloyd Doggett"
     And I should see "District 25"

  @uses_geocoder
  Scenario: Find my district (bogus zipcode)
     When I am on the homepage
      And I fill in "q" with "00000"
      And I press "Find"
     Then I should see "can't find that address"
