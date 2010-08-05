require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Home Page" do
  before do
    visit '/'
    response.should have_selector('.find_form > form > input#q')
  end

  it "given an address it should the show legislators in the area" do
    fill_in 'q', :with => '3306 French Place, Austin, TX 78722'
    click_button 'Find'

    current_url.should == 'search'

    response.should contain("District 25")
    response.should contain("District 14")

    response.should contain("Kirk Watson")
    response.should contain("Kay Bailey Hutchison")
    response.should contain("John Cornyn")
    response.should contain("Lloyd A. Doggett")
  end
end
