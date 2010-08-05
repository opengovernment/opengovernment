require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Home Page" do
  it do
    visit '/'
    response.should have_selector('.find_form > form > input#q')
  end
end
