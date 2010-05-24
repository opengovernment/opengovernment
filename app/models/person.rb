class Person < ActiveRecord::Base
  validates_inclusion_of :gender, :in => ["M", "F"], :allow_blank => true
  validates_presence_of :first_name, :last_name

  has_many :roles, :dependent => :destroy
  has_many :addresses, :dependent => :destroy
  has_many :committee_memberships, :dependent => :destroy
  has_many :committees, :through => :committee_memberships

  has_one :current_role, :class_name => 'Role'
  has_one :chamber, :through => :current_role

  named_scope :with_votesmart_id, :conditions => ["votesmart_id is not null"]
  named_scope :with_current_role, :include => :roles, :conditions => Role::CURRENT

  has_many :sponsorships, :foreign_key => "sponsor_id"
  has_many :sponsored_bills, :class_name => 'Bill', :through => :sponsorships, :source => :bill

  has_many :roll_calls
  has_many :votes, :through => :roll_calls

  has_many :citations, :as => :owner
  has_many :google_news_citations, :as => :owner, :class_name => "Citation", :conditions => {:search_source => "Google News"}
  has_many :google_blog_citations, :as => :owner, :class_name => "Citation", :conditions => {:search_source => "Google Blogs"}
  has_many :technorati_citations, :as => :owner, :class_name => "Citation", :conditions => {:search_source => "Technorati"}

  acts_as_citeable :keywords => [], :with => [:full_name]

  def full_name
    ([first_name, middle_name, last_name].join(' ') + (suffix? ? ", #{suffix}" : "")).squeeze(' ')
  end

  def official_name
    chamber ? [chamber.title, full_name].join(' ').squeeze(' ') : full_name
  end

  def youtube_url
    youtube_id.blank? ? nil : "http://www.youtube.com/user/" + youtube_id
  end

  def current_sponsorship_vitals
    Person.find_by_sql(["
      select * from (
        select
        -- this is a subquery because we want the max() to look at all rows
        y.sponsor_id as id,
        y.bill_count,
        y.rank,
        -- we have to do a max() here because you can't do max(row_number() over ..)
        max(y.rnum) over (partition by y.chamber_id) as total_sponsors
        from (
          select s.sponsor_id, s.chamber_id, s.bill_count, s.session_id,
          -- rank may have duplicates (3 people with rank #3),
          -- row_number does not.
          row_number() over w as rnum,
          rank() over w as rank
          from
            (select r.chamber_id, r.session_id, s0.sponsor_id,
            -- we're doing this subquery for the bill_count.
            count(*) as bill_count
            from sponsorships s0
            inner join roles r on s0.sponsor_id = r.person_id
            where (current_date between r.start_date and r.end_date)
            group by r.chamber_id, s0.sponsor_id, r.session_id) s
          window w as (partition by s.chamber_id, s.session_id order by s.bill_count desc)
        ) y
      ) z
      where z.id = ?
      limit 1", id]).first
  end

  def to_param
   "#{id}-#{full_name.parameterize}"
  end
end
