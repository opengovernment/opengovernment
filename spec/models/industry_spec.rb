require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Industry do
  before(:each) do
    @valid_attributes = {
      :name => "value for business_name",
      :parent_name => "value for industry_name"
    }
  end

  it "should create a new instance given valid attributes" do
    Industry.create!(@valid_attributes)
  end
end
