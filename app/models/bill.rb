class Bill < ActiveRecord::Base
  include Trackable

  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  with_options :dependent => :destroy do |hm|
    hm.has_many :sponsorships, :class_name => 'BillSponsorship'
    hm.has_many :versions, :class_name => 'BillVersion'
    hm.has_many :documents, :class_name => 'BillDocument'
    hm.has_many :actions
  end

  has_many :sponsors, :through  => :sponsorships
  has_many :major_actions, :class_name => 'Action', :conditions => ["kind <> 'other' and kind is not null"]
  has_many :votes, :dependent => :destroy

  scope :titles_like, lambda { |t| {:conditions => ["upper(bill_number) = ? or title like ?", "#{t.gsub(/[-\.\s]/, '').upcase.sub(/(([A-Z]\.?-?\s*){1,2})(\d+)/, '\1 \3')}", "%#{t}%"]} }

  # upper_and_stripped() is an indexed function on the bills table
  # that makes it easy to query consistently.
  scope :with_type_and_number, lambda { |t, n| {:conditions => ["upper_and_stripped(bill_number) = ?", (t.upcase + n.to_s).gsub(/[-\.\s]/, '')]}}
  scope :with_number, lambda { |n| with_type_and_number(n, '') }

  scope :in_chamber, lambda { |c| {:conditions => ["chamber_id = ?", c]} }
  scope :for_session, lambda { |s| {:conditions => ["session_id = ?", s], :joins => [:session]} }
  scope :for_session_named, lambda { |s| {:conditions => ["upper(sessions.name) = upper(?)", s], :joins => [:session]} }
  scope :with_key_votes, :conditions => {:votesmart_key_vote => true}
  scope :for_state, lambda { |s| {:conditions => ["state_id = ?", s]} }
  has_many :citations, :as => :owner

  with_options :as => :owner, :class_name => "Citation" do |c|
    c.has_many :google_news_citations, :conditions => {:search_source => "Google News"}
    c.has_many :google_blog_citations, :conditions => {:search_source => "Google Blogs"}
    c.has_many :technorati_citations, :conditions => {:search_source => "Technorati"}
  end

  acts_as_citeable :keywords => ["Bill"], :with => [:bill_number, "state.name"]

  has_many :bills_subjects
  has_many :subjects, :through => :bills_subjects

  # How will we allow people to sort bills?
  SORTABLE_BY = {
    "Date Introduced" => "first_action_at desc",
    "Title" => "title desc",
    "Recent Actions" => "last_action_at desc"
  }.freeze

  define_index do
    indexes title, :sortable => true
    has bill_number, state_id, session_id, chamber_id, last_action_at, first_action_at

    # Trigger the join on citations before indexing the count
    has citations(:id), :as => :citations_ids
    has "COUNT(citations.id)", :as => :citations_count, :type => :integer
  end

  class << self
    def find_by_session_name_and_param(session, param)
      for_session_named(session.titleize).find_by_bill_number(param.titleize.upcase)
    end

    def find_all_by_issue(issue)
      find_by_sql(["select * from v_tagged_bills
                where tag_name = ? order by last_action_at desc", issue.name])
    end
  end

  def to_hashtags
    "##{State.find(state_id).abbrev.downcase}bill ##{bill_number.downcase.gsub(' ', '')}"
  end

  def to_param
    bill_number.parameterize
  end
end
