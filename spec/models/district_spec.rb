require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe District do
  before do    
    @valid_attributes = {
      :name => "District 1",
      :district_type => DistrictType.find(:first),
      :state => State.find(:first)
    }
    # 3000 French Pl, Austin, TX 78722
    @french_pl_districts = District.find(:all, :conditions => {:census_sld => ["046", "014", "25"] })
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

  it "should allow us to find the correct districts by lat/long" do
    # 3000 French Pl, Austin, TX 78722
    districts = District.find_by_x_y(30.286308, -97.719782)
    districts.size.should eql(3)
    districts.should eql(@french_pl_districts)
  end

  it "should allow us to find the correct districts by address" do
    districts = District.find_by_address("3000 French Pl, Austin, TX")
    districts.size.should eql(3)
    districts.should eql(@french_pl_districts)
  end

end
