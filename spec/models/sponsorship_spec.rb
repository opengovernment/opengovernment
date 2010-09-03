require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Sponsorship do
  before(:each) do
    @bill = bills(:hb1000)
    @sponsor = people(:john)
    @valid_attributes = {
      :bill_id => @bill.id,
      :sponsor_id => @sponsor
    }
  end

  it "should allow a sponsor_name not both" do
    Sponsorship.create!(@valid_attributes)
    Sponsorship.create!(@valid_attributes.except(:sponsor_id).merge!({:sponsor_name => "test"}))
  end
  
  it "should not allow both a sponsor_name and a sponsor_id" do
    sponsorship = Sponsorship.new(@valid_attributes)
    sponsorship.sponsor_name = "test"
    sponsorship.should_not be_valid
    sponsorship.should have(1).errors_on(:base)
  end

  it "should require a sponsor_name or a sponsor_id" do
    sponsorship = Sponsorship.new(@valid_attributes.except(:sponsor_id))
    sponsorship.should_not be_valid
    sponsorship.should have(1).error_on(:sponsor_name)
    sponsorship.should have(1).error_on(:sponsor_id)
  end
end
