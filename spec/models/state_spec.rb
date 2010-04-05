require 'spec_helper'

describe State do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :abbrev => "value for abbrev",
      :unicameral => false,
      :fips_code => 1,
      :launch_date => Time.now
    }
  end

  it "should create a new instance given valid attributes" do
    State.create!(@valid_attributes)
  end
end
