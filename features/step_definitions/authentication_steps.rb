# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |email, password|
  user = Factory :user,
    :email                 => email,
    :password              => password,
    :password_confirmation => password
end

# Session

Then /^I should be signed in$/ do
  all('a', :text => 'Sign in').should be_blank
end

Then /^I should be signed out$/ do
  all('a', :text => 'Sign in').should be_present
end

When /^session is cleared$/ do
  Capybara.reset_sessions!
end

# Actions

When /^I sign in as "(.*)\/(.*)"$/ do |email, password|
  When %{I go to the sign in page}
  And %{I fill in "OpenCongress username" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Sign in"}
end

When /^I sign out$/ do
  When %{I follow "Sign out"}
end

When /^I return next time$/ do
  When %{session is cleared}
  And %{I go to the homepage}
end
