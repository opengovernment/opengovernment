require 'spec/spec_helper'

describe Session do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Session.create!(@valid_attributes)
  end
end
