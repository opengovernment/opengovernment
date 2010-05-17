require 'spec/spec_helper'

describe District do
  before do
    @valid_attributes = {
      :name => "District 1",
      :census_district_type => "LL",
      :state => State.first
    }
    # Using our test data,
    # 3000 French Pl, Austin, TX 78722 should return these districts:
    @french_pl_districts = District.find(:all, :conditions => {:census_sld => ["046", "014", "25"] })
    @district_14 = District.numbered('14')
  end

  it "should create a new instance given valid attributes" do
    District.create!(@valid_attributes)
  end

  it "should have one state associated with it" do
    district = District.create(@valid_attributes.except(:state))
    district.should_not be_valid
  end

  it "should always require a name" do
    # No name
    district = District.create(@valid_attributes.except(:name))
    district.save.should be_false
    district.errors_on(:name).should_not be_empty

    # Blank name
    district.name = ""
    district.save.should be_false
    district.errors_on(:name).should_not be_empty
  end

  it "should allow us to find the correct districts by lat/long" do
    # 3000 French Pl, Austin, TX 78722
    districts = District.for_x_y(30.286308, -97.719782)
    districts.size.should eql(3)
    districts.should eql(@french_pl_districts)
  end

  it "should allow us to find the correct districts by address" do
    districts = District.find_by_address("3000 French Pl, Austin, TX")
    districts.size.should eql(2)
    districts[1].size.should eql(3)
    districts[1].should eql(@french_pl_districts)
  end

  it "should return a district by number" do
    @district_14.size.should eql(1)
    @district_14.first.census_sld.should eql('014')
  end

  it "should return currently active legislators for a given district" do
    reps = @district_14.first.current_legislators
    reps.size.should eql(1)
  end

end
