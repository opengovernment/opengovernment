require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DistrictType do
  before(:each) do
    @valid_attributes = {
      :description => "Congressional District",
      :name => "LL"
    }
  end

  it "should create a new instance given valid attributes" do
    DistrictType.create!(@valid_attributes)
  end

end
