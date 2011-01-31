Feature: Search
  In order to deepen my understanding of politics
  As a citizen
  I want to search for information related to keywords

  @uses_geocoder
  Scenario: Successful search
    When I visit subdomain "tx"
     And I go to the homepage
     And I fill in "q" with "certain"
     And I press "Search"
    Then I should be on the search page
     And I should see "certain victims"
     And I should see "certain information"

  Scenario: Successful search with only one result
    When I visit subdomain "tx"
     And I go to the homepage
     And I fill in "q" with "john"
     And I press "Search"
    Then I should be on the person page for "John Cornyn"

  Scenario: Search with ^ and $ characters
    When I visit subdomain "tx"
     And I go to the home page
     And I fill in "q" with "$caret^"
     And I press "Search"
    Then I should be on the search page
     And I should see "0 results"
