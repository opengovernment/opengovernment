require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Action do
  before(:each) do
    @valid_attributes = {
    }
    @one = actions(:a1)
  end

  it "should create a new instance given valid attributes" do
    Action.create!(@valid_attributes)
  end

  it "should be able to find all actions on bills with a given issue tag" do
    Factory(:bills_subject)
    @tagging = Factory(:tagging)

    issue_actions = Action.find_all_by_issue(@tagging.tag)
    issue_actions.should have_at_least(1).actions
    issue_actions.each do |i|
      i.kinds.should_not be_empty
      i.kinds.should_not contain('other')
    end
  end
end
