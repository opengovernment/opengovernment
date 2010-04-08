require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DistrictType do
  before do
    @valid_attributes = {
      :description => "Congressional District",
      :name => "LL"
    }
    @district_type = DistrictType.new(@valid_attributes)
  end

  it "should create a new instance given valid attributes" do
    DistrictType.create!(@valid_attributes)
  end

  it "should meet all validation criteria" do
    @district_type.name = "ABC"
    @district_type.description = nil
    @district_type.save.should be_false
    @district_type.errors_on(:name).should_not be_empty
    @district_type.errors_on(:description).should_not be_empty
    
    @district_type.name = ""
    @district_type.save.should be_false
    @district_type.errors_on(:name).should_not be_empty
  end

end
