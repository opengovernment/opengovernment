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
