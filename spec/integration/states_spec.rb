require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "State Page" do
  fixtures :committees, :states

  before do
    @texas = states(:tx)
    @request.host = "#{@texas.abbrev}.example.org"
    visit root_url
    click_link 'Texas'
  end

  context "Left nav" do
    it "should render left side nav" do
      page.should have_css('.find_form > form > input#addr')

      within("nav#left_nav") do
        page.should have_link("Bills")
        page.should have_link("People")
        page.should have_link("Issues")
        page.should have_link("Campaign Contributions")

      end

      # the appeal link is, visually, in the left nav bar
      # but it's actually not in the left_nav element
      within("p.donate") do
        page.should have_link("About Us")
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

    it "should show people news" do 
      within("#people_mentions") do
        page.should have_content("Legislators in the News")
        page.should have_link("More")
      end
    end
  end

  context "Chamber tabs" do
    it "should show chamber info" do
      within("div#chamber_tabs") do
        page.should have_content("Each represents")
        page.should have_content("and serves four-year terms with a two-term limit.")
        page.should have_link('1 Committee')
        page.should have_link('0 Joint Committees')
        page.should have_link('0 Bills')
        page.should have_link('0 Key Votes')
      end
    end
  end


  context "Election Dates" do
    it "should show dates for next and last elections" do 
      page.should have_content "Next Election"
      page.should have_content "Last Election"
    end
  end
end
