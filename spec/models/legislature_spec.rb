require File.dirname(__FILE__) + '/../spec_helper'

describe Legislature do
  before(:each) do
    @valid_attributes = {
      :name => "Treehouse of Representatives"
    }
  end

  it "should create a new instance given valid attributes" do
    Legislature.create!(@valid_attributes)
  end
end
