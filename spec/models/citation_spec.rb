require File.dirname(__FILE__) + '/../spec_helper'

describe Citation do
  before(:each) do
    @valid_attributes = {

    }
  end

  it "should create a new instance given valid attributes" do
    Citation.create!(@valid_attributes)
  end
end
