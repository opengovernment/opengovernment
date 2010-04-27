require 'spec/spec_helper'

describe Person do
  before(:each) do
    @valid_attributes = {
      :first_name => "Lloyd",
      :last_name => "Doggett",
      :suffix => "Jr."
    }
  end

  it "should create a new instance given valid attributes" do
    Person.create!(@valid_attributes)
  end
  
  it "should allow finding people by an address" do
    people = Person.find_by_address("3000 French Pl, Austin, TX")
    people.size.should eql(5)
    # 2 Senators, 1 Representative, 1 upper chamber rep, 1 lower chamber rep
  end

  it "should return representatives full name" do
    person = Person.new(@valid_attributes)
    person.full_name.should eql("Lloyd Doggett, Jr.")
  end

end
