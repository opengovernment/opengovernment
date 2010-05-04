require 'spec_helper'

describe Action do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Action.create!(@valid_attributes)
  end
end
