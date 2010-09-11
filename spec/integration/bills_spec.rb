require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Bills Page" do
  before do
    @texas = states(:tx)
    @bills = Bill.for_state(@texas).unscoped

    @request.host = "#{@texas.abbrev}.example.org"
    visit bills_url
    page.should have_content("Texas Bills")
  end

  it "show the list of bills" do
    @bills.each do |bill|
      page.should have_link(bill.bill_number)
      page.should have_content(bill.title)
    end
  end
end
