require 'spec_helper'

describe District do
  before(:each) do
    @valid_attributes = {
      :name => "District 1",
      :district_type => DistrictType::LL,
      :state => State.find(:first)
    }
  end

  it "should create a new instance given valid attributes" do
    District.create!(@valid_attributes)
  end

  it "should have one state associated with it" do
    district = District.create(@valid_attributes.except(:state))
    district.should_not be_valid
  end
  
  it "should have one district type associated with it" do
    district = District.create(@valid_attributes.except(:district_type))
    district.should_not be_valid
  end

  it "should always require a name" do
    district = District.create(@valid_attributes.except(:name))
    district.should_not be_valid
    district.name = ""
    district.should_not be_valid
  end

end
