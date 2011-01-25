Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

    Scenario: User is not signed up
      Given no user exists with an email of "email@person.com"
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      Then I should see "Invalid email or password"
      And I should be signed out

   Scenario: User signs in successfully
      Given I signed up with "email@person.com/password"
      When I go to the sign in page
      And I sign in as "email@person.com/password"
      Then I should see "Signed in"
      And I should be signed in
