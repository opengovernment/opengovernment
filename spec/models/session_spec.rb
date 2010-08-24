require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Session do
  before(:each) do
    @valid_attributes = {

    }
  end

  it "should create a new instance given valid attributes" do
    Session.create!(@valid_attributes)
  end
  
  it "should return the correct special session number for given inputs" do
    session = Session.new(@valid_attributes.merge!({:parent_id => 1}))

    # No special session number
    session.name = '2000 Organizational Session'
    session.special_number.should be_nil

    # Single digit
    session.name = '1998 1st Extraordinary Session'
    session.special_number.should eql(1)

    # Multiple digit
    session.name = '1998 42nd Extraordinary Session'
    session.special_number.should eql(42)

    # Uppercase/lowercase
    session.name = '20092010 Special SESSION 6'
    session.special_number.should eql(6)
  end

end
