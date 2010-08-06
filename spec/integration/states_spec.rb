require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "State Page" do
  before do
    visit '/states/texas'
  end

  it "should render state info" do
    response.should have_selector('.find_form > form > input#q')
  end
end
