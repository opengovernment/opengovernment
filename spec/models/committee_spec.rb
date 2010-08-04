require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Committee do
  before(:each) do
    @valid_attributes = {
      :name => "Appropriations",
      :legislature => legislatures(:tx)
    }
  end

  it "should create a new instance given valid attributes" do
    Committee.create!(@valid_attributes)
  end

  context "associations" do
    before do
      @education = committees(:education)
      @appropriations = committees(:appropriations)
    end

    it "should connect to the parent committee via the votesmart IDs" do
      @education.parent.should eql(@appropriations)
    end
  end

end
