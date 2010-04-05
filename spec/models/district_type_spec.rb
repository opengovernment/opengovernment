require 'spec_helper'

describe DistrictType do
  before(:each) do
    @valid_attributes = {
      :name => "Congressional District",
      :lsad => "LL"
    }
  end

  it "should create a new instance given valid attributes" do
    DistrictType.create!(@valid_attributes)
  end


end
