require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe BillSponsorship do
  fixtures :bills, :people

  before(:each) do
    @bill = bills(:hb1000)
    @sponsor = people(:john)
    @valid_attributes = {
      :bill_id => @bill.id,
      :sponsor_id => @sponsor
    }
  end

  it "should allow a sponsor_name without a sponsor_id" do
    BillSponsorship.create!(@valid_attributes)
    BillSponsorship.create!(@valid_attributes.except(:sponsor_id).merge!({:sponsor_name => "test"}))
  end
  
  it "should require a sponsor_name or a sponsor_id" do
    sponsorship = BillSponsorship.new(@valid_attributes.except(:sponsor_id))
    sponsorship.should_not be_valid
    sponsorship.should have(1).error_on(:sponsor_name)
    sponsorship.should have(1).error_on(:sponsor_id)
  end
end
