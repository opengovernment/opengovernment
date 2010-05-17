require 'spec/spec_helper'

describe Bill do
  context "new" do
    before(:each) do
      @valid_attributes = {

      }
    end

    it "should create a new instance given valid attributes" do
      Bill.create!(@valid_attributes)
    end    
  end
  
  context "" do
    
  end
end
