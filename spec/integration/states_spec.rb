require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "State Page" do
  before do
    @texas = states(:tx)
    @request.host = "#{@texas.abbrev}.example.org"
    visit root_url
  end

  context "Left nav" do
    it "should render left side nav" do
      page.should have_css('.find_form > form > input#q')

      within("nav#left_nav") do
        page.should have_link("Bills")
        page.should have_link("People")
        page.should have_link("Issues")
        page.should have_link("Money Trail")
        page.should have_link("Pages")
        page.should have_link("Help Us Open Gov")
      end
    end

    it "nav links should take to the right pages" do
      within("nav#left_nav") do
        page.click_link("Bills")
        current_path.should == bills_path
      end
    end
  end

  context "Legislature info" do
    it "should show the basic info" do
      page.should have_content(@texas.legislature.name)
      page.should have_link("Official Site")
    end

    it "should show the candidate info" do
    end
  end

  context "Key Votes" do
  end
end
