require 'spec/spec_helper'

describe Person do
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

  it "should return a valid YouTube URL" do
    person = Person.new(@valid_attributes)
    person.youtube_url.should eql("http://www.youtube.com/user/" + person.youtube_id)
  end
end

