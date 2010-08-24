class Bill < ActiveRecord::Base
  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  has_many :sponsorships, :dependent => :destroy
  has_many :sponsors, :through  => :sponsorships

  has_many :versions, :dependent => :destroy
  has_many :actions, :dependent => :destroy
  has_many :major_actions, :class_name => 'Action', :conditions => ["kind <> 'other' and kind is not null"]
  has_many :votes, :dependent => :destroy

  default_scope :order => "first_action_at desc"
  scope :titles_like, lambda { |t| {:conditions => ["upper(bill_number) = ? or title like ?", "#{t.gsub(/[-.\s]/, '').upcase.sub(/(([A-Z]\.?-?\s*){1,2})(\d+)/, '\1 \3')}", "%#{t}%"]} }
  scope :in_chamber, lambda { |c| {:conditions => ["chamber_id = ?", c]} }
  scope :for_session, lambda { |s| {:conditions => ["session_id = ?", s], :joins => [:session]} }
  scope :for_session_named, lambda { |s| {:conditions => ["upper(sessions.name) = upper(?)", s], :joins => [:session]} }
  scope :with_key_votes, :conditions => {:votesmart_key_vote => true}
  scope :for_state, lambda { |s| {:conditions => ["state_id = ?", s]} }

  has_many :citations, :as => :owner
  has_many :google_news_citations, :as => :owner, :class_name => "Citation", :conditions => {:search_source => "Google News"}
  has_many :google_blog_citations, :as => :owner, :class_name => "Citation", :conditions => {:search_source => "Google Blogs"}
  has_many :technorati_citations, :as => :owner, :class_name => "Citation", :conditions => {:search_source => "Technorati"}

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
