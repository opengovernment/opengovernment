require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Bills Page" do
  fixtures :bills, :sessions, :states

  before do
    @texas = states(:tx)
    @session = sessions(:tx81)
    @bills = Bill.for_session_including_children(@session)

    @request.host = "#{@texas.abbrev}.example.org"
    visit root_url
    click_link 'Texas'
    click_link 'Bills'
    page.should have_content("Bills in the Texas Legislature")
  end

  it "show the list of bills" do
    @bills.each do |bill|
      page.should have_link(bill.bill_number)
      page.should have_content(truncate(bill.title, :length => 500))
    end
  end
end
