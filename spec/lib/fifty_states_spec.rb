require 'spec/spec_helper'
require 'lib/fifty_states'

#TODO: Mock http requests, rather than making an actual call to the api

module FiftyStates
  describe FiftyStates do
    it "should have the base uri set properly" do
      [State, Bill, Legislator].each do |klass|
        klass.base_uri.should == "http://fiftystates-dev.sunlightlabs.com/api"
      end
    end

    describe State do
      context "#find_by_abbrv" do
        before do
          #TODO: Mock request for State
        end
        it "should find a state by abbreviation" do
          lambda do
            @state = State.find_by_abbrv('ca')
          end.should_not raise_error

          @state.should_not be_nil
          @state.name.should == "California"
        end
      end
    end

    describe Bill do
      context "#find" do
        before do
          #TODO: Mock request for Bill
        end

        it "should find a bill by stat abbreviation, session, chamber, bill_id" do
          lambda do
            @bill = Bill.find('ca', 20092010, 'lower', 'AB667')
          end.should_not raise_error

          @bill.should_not be_nil
          @bill.title.should include("An act to amend Section 1750.1 of the Business and Professions Code, and to amend Section 104830 of")
        end
      end

      context "#search" do
        it "should find bills by given criteria" do
          @bills = Bill.search('agriculture')

          @bills.should_not be_nil
          @bills.collect(&:bill_id).should include("S 0438")
        end
      end

      context "#latest" do
        it "should get the latest bills by given criteria" do
          lambda do
            @latest = Bill.latest('2010-01-01','sd')
          end.should_not raise_error

          @latest.collect(&:bill_id).should include("SB 7")
        end
      end
    end

    describe Legislator do
      before do
        #TODO: Mock request for legislator
      end
      context "#find" do
        it "should get the latest bill" do
          lambda do
            @legislator = Legislator.find(2462)
          end.should_not raise_error

          @legislator.first_name.should == "Dave"
          @legislator.last_name.should == "Cox"
        end
      end
      context "#search" do
        it "should get legislators by given criteria" do
          lambda do
            @legislators = Legislator.search(:state => 'ca')
          end.should_not raise_error

          @legislators.should_not be_nil
        end
      end
    end
  end
end
