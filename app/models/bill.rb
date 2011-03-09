class Bill < ActiveRecord::Base
  include Trackable

  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  with_options :dependent => :destroy do |hm|
    hm.has_many :sponsorships, :class_name => 'BillSponsorship'
    hm.has_many :versions, :class_name => 'BillVersion'
    hm.has_many :documents, :class_name => 'BillDocument'
    hm.has_many :actions do
      def has_kind?(kind)
        exists?(["? in (actions.kind_one, actions.kind_two, actions.kind_three)", kind])
      end
      
      def of_kind(kind)
        where(["? in (actions.kind_one, actions.kind_two, actions.kind_three)", kind]).order('actions.date desc').first
      end

      {:introduced => 'bill:introduced', 
       :referred_to_committee => 'committee:referred',
       :passed => 'bill:passed',
       :failed => 'bill:failed',
       :signed => 'governor:signed'}.each do |label, kind|
        define_method("#{label}?") { self.send('has_kind?', kind) }
        define_method("first_#{label}") { self.send('of_kind', kind) }
      end
    end
  end

  has_many :sponsors, :through  => :sponsorships
  has_many :major_actions, :class_name => 'Action', :conditions => ["kind_one <> 'other' and kind_one is not null"]
  has_many :votes, :dependent => :destroy

  scope :titles_like, lambda { |t| {:conditions => ["upper(bill_number) = ? or title like ?", "#{t.gsub(/[-\.\s]/, '').upcase.sub(/(([A-Z]\.?-?\s*){1,2})(\d+)/, '\1 \3')}", "%#{t}%"]} }

  # upper_and_stripped() is an indexed function on the bills table
  # that makes it easy to query consistently.
  scope :with_type_and_number, lambda { |t, n| {:conditions => ["upper_and_stripped(bill_number) = ?", (t.upcase + n.to_s).gsub(/[-\.\s]/, '')]}}
  scope :with_number, lambda { |n| with_type_and_number(n, '') }

  scope :in_chamber, lambda { |c| {:conditions => ["chamber_id = ?", c]} }
  scope :for_session, lambda { |s| {:conditions => ["session_id = ?", s], :joins => [:session]} }
  scope :for_session_named, lambda { |s| {:conditions => ["upper(sessions.name) = upper(?)", s], :joins => [:session]} }
  scope :for_session_including_children, lambda { |s| {:conditions => ["session_id in (select id from sessions where id = ? or parent_id = ?)", s, s], :joins => [:session]} }

  scope :in_a_current_session, {:conditions => ["session_id in (select id from v_most_recent_sessions union select parent_id from v_most_recent_sessions)"]}

  scope :with_key_votes, :conditions => {:votesmart_key_vote => true}
  scope :without_key_votes, :conditions => {:votesmart_key_vote => false}

  scope :for_state, lambda { |s| {:conditions => ["state_id = ?", s]} }

  # Creates #mentions associations.
  acts_as_noteworthy :with => [:bill_number, "state.name"]

  has_many :citations, :as => :citeable
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

    # Trigger the join on mentions before indexing the count
    # We're using SQL to do this now... so no need to index it.
    #has mentions(:id), :as => :mentions_ids
    #has "COUNT(mentions.id)", :as => :mentions_count, :type => :integer
  end
  
  def kinds
    [kind_one, kind_two, kind_three].compact
  end

  def long_id
    [State.find(state_id).abbrev.downcase, session.to_param, bill_number.downcase.gsub(' ', '')].join('-')
  end
  
  def title_fm
    bill_number + ': ' + title
  end

  def self.find_by_slug(param)
    find_by_bill_number(param.titleize.upcase)
  end

  def self.by_state_and_issue(state_id, issue, limit = 10)
    find_by_sql(["select * from v_tagged_bills
              where tag_name = ? and state_id = ? order by last_action_at desc limit ?", issue.name, state_id, limit])
  end

  def to_hashtags
    "##{State.find(state_id).abbrev.downcase}bill ##{bill_number.downcase.gsub(' ', '')}"
  end

  def as_json(opts = {})
    super(opts.merge({
      :methods => :views,
      :include => {
        :actions => {:except => :bill_id },
        :votes => {:except => :bill_id},
        :documents => {},
        :versions => {},
        :subjects => {},
        :sponsorships => {:except => [:id, :bill_id]},
        :citations => {:except => [:id, :bill_id, :citeable_id, :citeable_type]} } }))
  end

  def to_param
    bill_number.parameterize
  end
end
