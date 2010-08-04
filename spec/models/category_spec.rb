require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Category do
  before(:each) do
    @valid_attributes = {
      :name => "",
      :votesmart_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Category.create!(@valid_attributes)
  end
end
