require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Page do
  before(:all) do
    Page.delete_all
    @valid_attributes = {
      :countable_id => 1,
      :countable_type => 'Bill'}
  end

  it "should create a page" do
    @page = Page.create(
      @valid_attributes
    )
    @page.save.should be_true
  end

  it "should validate uniqueness" do
    dupe_page = Page.new(@valid_attributes)
    dupe_page.save.should be_false
    dupe_page.should_not be_valid
  end

  it "should have a count of zero when no views exist" do
    new_page = Page.new(
      :countable_id => 2,
      :countable_type => 'Bill')
    new_page.view_count.should == 0
    
    new_page.save
    new_page.view_count.should == 0

    new_page.views << PageView.new(
      :count => 5,
      :hour => Time.now.beginning_of_hour
    )
    new_page.save
  end

  it "should be able to sum all view counts" do
    @page = Page.first
    @page.views << PageView.new(
      :count => 5,
      :hour => Time.now.beginning_of_hour
    )
    @page.save
    @new_page.view_count.should == 5
  end

  it "should be able to sum all view counts since a given date" do
    @page = Page.first
    @page.views << PageView.new(
      :count => 1,
      :hour => Time.mktime(1991, 1, 1, 2)
    )
    @page.save
    @new_page.view_count_since(2.hours.ago).should == 5
  end

  it "should sum multiple views when calculating counts" do
    @new_page.view_count.should == 6
  end

  it "should be able to calculate an ordered list of most viewed pages" do
    Page.most_viewed.should have(5).pages
  end

end
