require File.dirname(__FILE__) + '/../spec_helper'

describe RollCall do
  before(:each) do
    @valid_attributes = {

    }
  end

  it "should create a new instance given valid attributes" do
    RollCall.create!(@valid_attributes)
  end
end
