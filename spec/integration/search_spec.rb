require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Search" do
  fixtures :states

  before do
    @texas = states(:tx)
    @request.host = "#{@texas.abbrev}.example.org"
    visit root_url
  end

  it "should have the search box" do
    within("header") do
      within("div.search_form > form") do
        page.should have_css("select")
        page.should have_css("input#q")
      end
    end
  end

  context "by everything" do
    it "should show all the search results" do
      within("header > div.search_form > form") do

      end
    end
  end

  context "by bills" do
    it "should show matching bills" do
      within("header > div.search_form > form") do

      end
    end
  end

  context "by legislators" do
    it "should show matching legislators" do
      within("header > div.search_form > form") do

      end
    end
  end

  context "by committes" do
    it "should show matching committees" do
      within("header > div.search_form > form") do

      end
    end
  end

  context "by contributions" do
    it "should show matching contributions" do
      within("header > div.search_form > form") do

      end
    end
  end
end
