require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Role do
  fixtures :people, :states

  before(:each) do
    @valid_attributes = {
      :senate_class => 1,
      :start_date => Time.now,
      :end_date => 2.days.from_now,
      :person => Person.first,
      :state => State.first
    }
  end

  it "should create a new instance given valid attributes" do
    Role.create!(@valid_attributes)
  end

  it "should restrict start and end dates appropriately" do
    role = Role.new(@valid_attributes)
    role.save.should be_true

    role.end_date = 2.days.ago
    role.save.should be_false

    # end date can be null
    role.end_date = nil
    role.save.should be_true
  end

  it "should have a chamber" do

  end
end
