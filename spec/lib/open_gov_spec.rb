require File.dirname(__FILE__) + '/../spec_helper'
require Rails.root + 'lib/open_gov'

describe "OpenGov::Date" do
  describe ".valid_date!" do
    it "should return a valid date given a float" do
      OpenGov::Date::valid_date!(1242187200.0).should == Date.parse("Tue, 12 May 2009")
    end

    it "should return a date given a string" do
      OpenGov::Date::valid_date!("Tue, 12 May 2009").should == Date.parse("Tue, 12 May 2009")
    end

    it "should return a date given a date" do
      OpenGov::Date::valid_date!(Date.parse("Tue, 12 May 2009")).should == Date.parse("Tue, 12 May 2009")
    end

    it "should return nil if passed nil" do
      OpenGov::Date::valid_date!(nil).should be_nil
    end

    it "should raise a TypeError for an unrecognized type" do
      lambda { OpenGov::Date::valid_date!(Object.new) }.should raise_error(TypeError)
    end
  end
end
