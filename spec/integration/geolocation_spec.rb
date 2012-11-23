require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Geolocation" do
  fixtures :states

  before do
    @texas = states(:tx)
    @request.host = "#{@texas.abbrev}.example.org"
    visit root_url
  end

  it "should have the geo location box" do
    within("div.find_box") do

    end
  end
end
