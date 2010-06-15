require 'spec_helper'

describe SpecialInterestGroup do
  before(:each) do
    @valid_attributes = {
      :contact_name => ,
      :city => ,
      :address => ,
      :name => ,
      :zip => ,
      :state_id => ,
      :url => ,
      :phone_one => ,
      :votesmart_id => ,
      :phone_two => ,
      :description => ,
      :email => "value for email",
      :fax => "value for fax"
    }
  end

  it "should create a new instance given valid attributes" do
    SpecialInterestGroup.create!(@valid_attributes)
  end
end
