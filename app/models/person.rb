class Person < ActiveRecord::Base
  validates_inclusion_of :gender, :in => ["M", "F"], :allow_blank => true
  validates_presence_of :first_name, :last_name

  has_many :roles, :dependent => :destroy
  has_many :addresses, :dependent => :destroy
  has_many :committee_memberships, :dependent => :destroy
  has_many :committees, :through => :committee_memberships

  has_one :current_role, :class_name => 'Role', :conditions => Role::CURRENT
  has_one :chamber, :through => :current_role

  scope :with_votesmart_id, :conditions => ["votesmart_id is not null"]
  scope :with_nimsp_candidate_id, :conditions => ["nimsp_candidate_id is not null"]
  scope :with_current_role, :include => :roles, :conditions => Role::CURRENT

  has_many :sponsorships, :foreign_key => "sponsor_id"
  has_many :sponsored_bills, :class_name => 'Bill', :through => :sponsorships, :source => :bill

  has_many :contributions, :foreign_key => "candidate_id", :order => "amount desc", :limit => 20
  has_many :ratings, :order => "timespan desc"

  has_many :business_contributions, :foreign_key => "candidate_id",
           :class_name => "Contribution",
           :finder_sql => %q{
              SELECT b.business_name, sum(c.amount) as amount
              FROM businesses b
              inner join contributions c on c.business_id = b.id
              where c.candidate_id = #{self.id}
              group by b.business_name
              order by amount desc
              limit 20
          }

  has_many :industry_contributions, :class_name => "Contribution",
           :finder_sql => %q{
              SELECT b.industry_name, sum(c.amount) as amount
              FROM businesses b
              inner join contributions c on c.business_id = b.id
              where c.candidate_id = #{self.id}
              group by b.industry_name
              order by amount desc
              limit 20
          }

  has_many :sector_contributions, :foreign_key => "candidate_id",
           :class_name => "Contribution",
           :finder_sql => %q{
              SELECT b.sector_name, sum(c.amount) as amount
              FROM businesses b
              inner join contributions c on c.business_id = b.id
              where c.candidate_id = #{self.id}
              group by b.sector_name
              order by amount desc
              limit 20
          }

  has_many :roll_calls do
    def yes
      find(:all, :conditions => {:vote_type => 'yes'})
    end

    def no
      find(:all, :conditions => {:vote_type => 'no'})
    end

    def other
      find(:all, :conditions => {:vote_type => 'other'})
    end
  end

  has_many :votes, :through => :roll_calls, :order => "date desc" do
    def latest
      find(:all, :limit => 5)
    end
  end

  has_many :citations, :as => :owner

  with_options :as => :owner, :class_name => "Citation" do |c|
    c.has_many :google_news_citations, :conditions => {:search_source => "Google News"}
    c.has_many :google_blog_citations, :conditions => {:search_source => "Google Blogs"}
    c.has_many :technorati_citations, :conditions => {:search_source => "Technorati"}
  end

#  acts_as_citeable :keywords => [], :with => [:full_name]

  # How will we allow people to sort bills?
  SORTABLE_BY = {
    "First Name" => "first_name asc",
    "Last Name" => "last_name asc"
  }.freeze

  define_index do
    indexes first_name, middle_name, last_name, :sortable => true
    has email
  end

  def full_name
    ([first_name, middle_name, last_name].join(' ') + (suffix? ? ", #{suffix}" : "")).squeeze(' ')
  end

  def gender_fm
    case gender
    when "M"
      "Male"
    when "F"
      "Female"
    else
      "Other"
    end
  end

  def gender_class
    gender_fm.parameterize
  end

  def official_name
    chamber ? [chamber.title, full_name].join(' ').squeeze(' ') : full_name
  end

  def wiki_name
    normalized_names = [first_name, last_name].map {|name| name.mb_chars.normalize(:kd).gsub(/[^\-x00-\x7F]/n, '')}
    normalized_names.join(' ').gsub(' ', '_')
  end

  def youtube_url
    youtube_id.blank? ? nil : "http://www.youtube.com/user/" + youtube_id
  end

  def affiliation
    return "" unless self.current_role

    district = self.current_role.district

    # TODO: This is very data-dependent; this should be cleaned up or dealt with on import.
    party = case self.current_role.party
      when "Democrat"
        "D"
      when "Republican"
        "R"
      when ""
        ""
      else
        "I"
    end

    if !party.blank? && !district.blank? && !district.number.blank?
      "(#{party}-#{district.number})"
    else
      nil
    end
  end

  def has_contributions?
    !(self.contributions | self.industry_contributions | self.business_contributions | self.sector_contributions).blank?
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

  def photo_url
    self.openstates_photo_url || self.votesmart_photo_url || 'missing.png'
  end
end
