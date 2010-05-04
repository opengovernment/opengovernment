require 'spec/spec_helper'

describe Sponsorship do
  before(:each) do
    @valid_attributes = {

    }
  end

  it "should create a new instance given valid attributes" do
    Sponsorship.create!(@valid_attributes)
  end
end
