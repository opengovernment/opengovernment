require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Chamber do
  before(:each) do
    @valid_attributes = {
      :term_length => 2,
      :legislature => Legislature.first
    }
  end

  it "should create a new instance given valid attributes" do
    Chamber.create!(@valid_attributes)
  end

end
