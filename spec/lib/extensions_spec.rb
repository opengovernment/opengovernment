require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require Rails.root + 'lib/extensions'

describe "Date" do
  describe ".valid_date!" do
    it "should return a valid date given a float" do
      Date.valid_date!(1242187200.0).should == Date.parse("Tue, 12 May 2009")
    end

    it "should return a date given a string" do
      Date.valid_date!("Tue, 12 May 2009").should == Date.parse("Tue, 12 May 2009")
    end

    it "should return a date given a date" do
      Date.valid_date!(Date.parse("Tue, 12 May 2009")).should == Date.parse("Tue, 12 May 2009")
    end

    it "should return nil if passed nil" do
      Date.valid_date!(nil).should be_nil
    end

    it "should raise a TypeError for an unrecognized type" do
      lambda { Date.valid_date!(Object.new) }.should raise_error(TypeError)
    end
  end
end

describe "Integer" do
  describe "scale" do
    # No change in scale
    Integer.scale(1, 1, 1).should == 1

    # Scale down
    Integer.scale(1, 1, 0.5).should == 0.5

    # Scale a zero
    Integer.scale(0, 1, 1).should == 0
    Integer.scale(0, 1, 0.5).should == 0

    # Scale up
    Integer.scale(5, 10, 100).should == 50
  end
end

describe "Time" do
  describe "beginning_of_hour" do
    Time.mktime(1991, 1, 1, 2, 31, 22).beginning_of_hour.should == Time.mktime(1991, 1, 1, 2)
  end
end
