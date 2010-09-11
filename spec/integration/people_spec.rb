require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "People" do
  before do
    @texas = states(:tx)
    @request.host = "#{@texas.abbrev}.example.org"
    visit people_url
  end

  context "Upper House" do

  end

  context "Lower House" do

  end
end
