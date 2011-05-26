require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "State Page" do
  before do
    @texas = states(:tx)
    @request.host = "#{@texas.abbrev}.example.org"
    visit root_url
    click_link 'Texas'
  end

  context "Left nav" do
    it "should render left side nav" do
      page.should have_css('.find_form > form > input#q')


      within("nav#left_nav") do
        page.should have_link("Bills")
        page.should have_link("People")
        page.should have_link("Issues")
        page.should have_link("Money Trail")

        # this seems to have been removed from the navigation, 
        # so I'm removing it from the spec.
        # page.should have_link("Pages")

      end

      # the appeal link is, visually, in the left nav bar
      # but it's actually not in the left_nav element
      within("div.grid_4") do
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
      within("div.people_news_preview") do
        page.should have_content("People in the News")
        page.should have_link("See All")
      end
    end

    it "should show the candidate info" do
    end


    it "should show bill info" do
      page.should have_link("Recent Bills")
      page.should have_link("Key Votes")
      page.should have_link("Project Vote Smart")
      page.should have_link("What's a key vote?")
      page.should have_link("All Key Votes")
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

  context "Key Votes" do
  end
end


