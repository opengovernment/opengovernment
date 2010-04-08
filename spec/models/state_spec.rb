require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe State do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :abbrev => "value for abbrev",
      :unicameral => false,
      :fips_code => 1
    }
  end

  it "should create a new instance given valid attributes" do
    State.create!(@valid_attributes)
  end

  it "should show unsupported states" do
    unsupported_state = State.create(@valid_attributes)
    State.unsupported.should include unsupported_state
  end

end
