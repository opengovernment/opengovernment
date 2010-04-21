require 'spec/spec_helper'

describe Chamber do
  before(:each) do
    @valid_attributes = {
      :term_length => 2
    }
  end

  it "should create a new instance given valid attributes" do
    Chamber.create!(@valid_attributes)
  end
  
  it "should properly find the upper and lower chambers" do

  end

end
