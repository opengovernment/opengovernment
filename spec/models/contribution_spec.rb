require 'spec_helper'

describe Contribution do
  before(:each) do
    @valid_attributes = {
      :business_name => "value for business_name",
      :contributor_state => "value for contributor_state",
      :industry_name => "value for industry_name",
      :contributor_occupation => "value for contributor_occupation",
      :contributor_employer => "value for contributor_employer",
      :amount => "value for amount",
      :date => Date.today,
      :sector_name => "value for sector_name",
      :nimsp_industry_code => 1,
      :nimsp_sector_code => 1,
      :contributor_city => "value for contributor_city",
      :contributor_name => "value for contributor_name",
      :contributor_zipcode => "value for contributor_zipcode"
    }
  end

  it "should create a new instance given valid attributes" do
    Contribution.create!(@valid_attributes)
  end
end
