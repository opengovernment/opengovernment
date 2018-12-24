require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Action do
  fixtures :actions, :bills_subjects, :states, :subjects

  before(:each) do
    @valid_attributes = {
    }
    @one = actions(:a1)
  end

  it "should create a new instance given valid attributes" do
    Action.create!(@valid_attributes)
  end

  it "should be able to find all actions on bills with a given issue tag" do
    @subject = subjects(:education)
    @tag = ActsAsTaggableOn::Tag.create! :name => 'education'
    @tagging = ActsAsTaggableOn::Tagging.create! :taggable => @subject, :tag => @tag, :context => 'issues'
    @bills_subject = bills_subjects(:education)
    @texas = states(:tx)

    issue_actions = Action.by_state_and_issue(@texas, @tagging.tag)
    issue_actions.should have_at_least(1).actions
    issue_actions.each do |i|
      i.kinds.should_not be_empty
      i.kinds.should_not include('other')
    end
  end
end
