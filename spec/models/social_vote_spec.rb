require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# describe SocialVote do
#   before(:all) do
#     SocialVote.delete_all
#     @valid_attributes = {
#       :countable_id => 1,
#       :countable_type => 'Bill'}
#       
#     @this_hour = Time.now.beginning_of_hour
#   end
# 
#   it "should create a vote" do
#     @page = SocialVote.new(
#       @valid_attributes
#     )
#     @page.save.should be_true
#   end
# 
#   context "using our saved page" do
#     before(:each) do
#       @page = SocialVote.first
#     end
# 
#     it "should validate uniqueness" do
#       dupe_vote = SocialVote.new(@valid_attributes)
#       dupe_vote.save.should be_false
#       dupe_vote.should_not be_valid
#     end
#   end
# end