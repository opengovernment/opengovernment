require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Person do
  fixtures :bills, :bill_sponsorships, :chambers, :legislatures, :people, :roles, :sessions, :states

  before do
    @john = people(:john)
  end

  context "validations" do
    before(:each) do
      @valid_attributes = {
        :first_name => "Lloyd",
        :last_name => "Doggett",
        :suffix => "Jr.",
        :youtube_id => "Llyody123"
      }
    end

    it "should create a new instance given valid attributes" do
      Person.create!(@valid_attributes)
    end

    it "should return representatives full name" do
      person = Person.new(@valid_attributes)
      person.full_name.should eql("Lloyd Doggett, Jr.")
    end
  end

  describe "with_votesmart_id" do
    it "should return person by votesmart id" do
      Person.with_votesmart_id.each do |person|
        person.votesmart_id.should_not be_nil
      end
    end
  end

  describe "with_current_role" do
    it "should return person by votesmart id" do
      Person.with_current_role.each do |person|
        person.roles.should_not be_nil
        person.roles.select {|r| r.current? }.should have_at_least(0).roles
      end
    end
  end

  describe "full_name" do
    it "should return representatives full name" do
      @john.full_name.should eql("John Cornyn")
    end
  end

  describe "official_name" do
    it "should show full name if the given person does not have a chamber" do
      @john.should_receive(:chamber).and_return(nil)
      @john.official_name.should eql("John Cornyn")
    end

    it "should return the official name" do
      @john.official_name.should eql("Senator John Cornyn")
    end
  end

  describe "youtube_url" do
    it "should return a valid YouTube URL" do
      @john.youtube_url.should eql("http://www.youtube.com/user/" + @john.youtube_id)
    end
  end

  describe "to_param" do
    it "should return parameterized value for a given person" do
      @john.to_param.should eql("#{@john.id}-john-cornyn")
    end
  end

  describe "current_sponsorship_vitals" do
    it "should return vital statistics" do
      cvls = @john.current_sponsorship_vitals
      cvls.should respond_to(:rank)
      cvls.should respond_to(:bill_count)
      cvls.should respond_to(:total_sponsors)
      cvls.id.should == @john.id
    end
  end
end

