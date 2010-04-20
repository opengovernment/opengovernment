require 'spec_helper'

describe Person do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Person.create!(@valid_attributes)
  end
  
  it "should allow finding people by an address" do
    people = People.find_by_address("3000 French Pl, Austin, TX")
    people.size.should eql(5)
    # 2 Senators, 1 Congressional rep, 1 upper house rep, 1 lower house rep
  end

  it "should belong to a "
  end
end
