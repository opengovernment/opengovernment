require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe Page do
  before(:all) do
    Page.delete_all
    PageView.delete_all
    @valid_attributes = {
      :countable_id => 1,
      :countable_type => 'Bill'}
      
    @this_hour = Time.now.beginning_of_hour
  end

  it "should create a page" do
    @page = Page.new(
      @valid_attributes
    )
    @page.save.should be_true
  end

  context "using our saved page" do
    before(:each) do
      @page = Page.first
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

      new_page.page_views << PageView.new(
        :total => 5,
        :hour => @this_hour
      )
      new_page.save
    end

    it "should be able to sum all view counts" do
      @page.page_views << PageView.new(
        :total => 5,
        :hour => @this_hour
      )
      @page.save
      @page.view_count.should == 5
    end
    
    it "should be able to find a page by the object id and type" do
      @page = Page.by_object('Bill', 1)
      @page.should have(1).page
      @page.first.countable_id.should == 1
      @page.first.countable_type.should == 'Bill'
    end

    it "should be able to sum all view counts since a given date" do
      @page.page_views << PageView.new(
        :total => 1,
        :hour => Time.mktime(1991, 1, 1, 2)
      )
      @page.save
      @page.view_count_since(2.hours.ago).should == 5
    end

    it "should increment the view total when a hit occurs during the same hour" do
      @page_view = PageView.where(:page_id => @page.id, :hour => @this_hour).first
      @page_view.total.should == 5

      lambda do
        @page.mark_hit
        @page_view.reload
      end.should change(@page_view, :total).by(1)
    end

    it "should sum multiple views when calculating counts" do
      @page.view_count.should == 7
    end

    it "should be able to calculate an ordered list of most viewed pages" do
      Page.most_viewed('Bill').should have(2).pages
    end

  end
end
