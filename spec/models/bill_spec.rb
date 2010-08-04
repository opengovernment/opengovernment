require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
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

  context "named scopes" do
    before do
      @tx = states(:tx)
      @txl = chambers(:txl)
      @tx81 = sessions(:tx81)
      @hb1000 = bills(:hb1000)
    end

    describe ".titles_like" do
      it "should return bills with a given title" do
        Bill.titles_like("prekindergarten").size.should eql(1)
      end

      it "should return bills with a given bill number" do
        Bill.titles_like("HB 1000").size.should eql(1)
        Bill.titles_like("HB 1000").first.should eql(@hb1000)
      end

      it "should allow bill numbers supplied in a variety of formats" do
        Bill.titles_like("hb1000").first.should eql(@hb1000)
        Bill.titles_like("h.b.1000").first.should eql(@hb1000)
        Bill.titles_like("H.B.1000").first.should eql(@hb1000)
        Bill.titles_like("hb 1000").first.should eql(@hb1000)
      end
    end

    describe ".in_chamber" do
      it "should return bills with a given chamber" do
        Bill.in_chamber(@txl).size.should eql(@txl.bills.size)
      end
    end

    describe "for_session" do
      it "should return bills with a given session" do
        Bill.for_session(@tx81.id).size.should eql(@tx81.bills.size)
      end
    end

    describe "for_session_named" do
      it "should return bills for a given session name" do
        Bill.for_session_named(@tx81.name).size.should eql(@tx81.bills.size)
      end
    end

    describe "for_state" do
      it "should return bills with a given state" do
        Bill.for_state(@tx.id).size.should eql(@tx.bills.size)
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
