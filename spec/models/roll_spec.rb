require 'spec/spec_helper'

describe Roll do
  before(:each) do
    @valid_attributes = {

    }
  end

  it "should create a new instance given valid attributes" do
    Roll.create!(@valid_attributes)
  end
end
