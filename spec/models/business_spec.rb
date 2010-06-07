require 'spec_helper'

describe Business do
  before(:each) do
    @valid_attributes = {
      :business_name => "value for business_name",
      :industry_name => "value for industry_name",
      :sector_name => "value for sector_name",
      :nimsp_industry_code => 1,
      :nimsp_sector_code => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Business.create!(@valid_attributes)
  end
end
