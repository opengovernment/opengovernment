require 'spec_helper'

describe Rating do
  before(:each) do
    @valid_attributes = {
      :rating => "",
      :timespan => "",
      :sig_id => "",
      :votesmart_id => "",
      :rating_text => "value for rating_text"
    }
  end

  it "should create a new instance given valid attributes" do
    Rating.create!(@valid_attributes)
  end
end
