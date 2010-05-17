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

    context "validations" do

    end
  end

  context "named scopes" do
    describe ".titles_like" do
      it "should return bills with a given title" do

      end

      it "should return bills with a given bill number" do

      end
    end

    describe ".in_chamber" do
      it "should return bills with a given chamber" do

      end
    end

    describe "for_session" do
      it "should return bills with a given session" do

      end
    end

    describe "for_state" do
      it "should return bills with a given state" do

      end
    end
  end

  context "search" do
    it "should return bills" do

    end

    describe "find_by_session_name_and_params" do
      it "should return bills given session name and params" do

      end
    end
  end

  describe "#to_param" do
    it "should return a parameterized bill number" do

    end
  end
end
