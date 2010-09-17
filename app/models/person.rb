require 'open-uri'

class Person < ActiveRecord::Base
  include Trackable
  has_attached_file :photo, :styles => {:full => "110x110>", :thumb => "50x50#"}
  acts_as_citeable :with => [:official_name]

  validates_inclusion_of :gender, :in => ["M", "F"], :allow_blank => true
  validates_presence_of :first_name, :last_name

  [:website_one, :website_two, :webmail].each do |prop|
    validates_format_of prop, :with => URI::regexp(%w(http https)), :allow_nil => true
  end

  # We could ask for a photo URL on a form this way, if we wanted.
  # Right now this is used by OpenStates::Photos::sync! to
  # download photos for each person.
  attr_accessor :photo_url
  before_validation :download_remote_image, :if => :photo_url_provided?
  validates_presence_of :openstates_photo_url, :if => :photo_url_provided?, :message => 'is invalid or inaccessible'

  has_many :roles, :dependent => :destroy
  has_many :addresses, :dependent => :destroy
  has_many :committee_memberships, :dependent => :destroy
  has_many :committees, :through => :committee_memberships

  has_and_belongs_to_many :current_roles, :join_table => "v_most_recent_roles", :class_name => 'Role'
  has_one :chamber, :through => :current_roles

  has_many :sponsorships, :foreign_key => "sponsor_id"
  has_many :sponsored_bills, :class_name => 'Bill', :through => :sponsorships, :source => :bill

  has_many :contributions, :order => "amount desc", :limit => 20
  has_many :ratings, :order => "timespan desc"

# The queries below roll up contributions, relying on the ancestry column
# of corporate_entities.
#
# They assume that sectors always have null ancestry,
# industries are always children of sectors
# and businesses are at the third level.
#
# These queries also assume that contributions are ONLY associated
# with Businesses.
#  ancestry |  id  | name                           | type                
#           |   40 | Construction                   | Sector
#  40       |   41 | General Contractors            | Industry
#  40/41    |  636 | Construction & public works    | Business

  has_many :business_contributions, :foreign_key => "person_id",
           :class_name => "Contribution",
           :finder_sql => %q{
              SELECT b.name, sum(c.amount) as amount
              FROM corporate_entities b
              inner join contributions c on c.corporate_entity_id = b.id
              where c.person_id = #{id}
              group by b.name
              order by amount desc
              limit 20
          }

  has_many :industry_contributions, :foreign_key => "person_id",
           :class_name => "Contribution",
           :finder_sql => %q{
             SELECT b2.id, b2.name, sum(c.amount) as amount
             FROM corporate_entities b
             inner join contributions c on c.corporate_entity_id = b.id
             inner join corporate_entities b2 on b.ancestry like '%/' || b2.id
             where c.person_id = #{id}
             group by b2.id, b2.name
             order by amount desc
             limit 20
          }

  has_many :sector_contributions, :foreign_key => "person_id",
           :class_name => "Contribution",
           :finder_sql => %q{
             SELECT b2.id, b2.name, sum(c.amount) as amount
             FROM corporate_entities b
             inner join contributions c on c.corporate_entity_id = b.id
             inner join corporate_entities b2 on b.ancestry like b2.id || '/%'
             where c.person_id = #{id}
             group by b2.id, b2.name
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

  has_many :votes, :through => :roll_calls do
    def latest(n = 5)
      limit(n)
    end
  end

  has_many :citations, :as => :owner

  with_options :as => :owner, :class_name => "Citation" do |c|
    c.has_many :google_news_citations, :conditions => {:search_source => "Google News"}
    c.has_many :google_blog_citations, :conditions => {:search_source => "Google Blogs"}
    c.has_many :technorati_citations, :conditions => {:search_source => "Technorati"}
  end

  scope :with_votesmart_id, :conditions => ["votesmart_id is not null"]
  scope :with_nimsp_candidate_id, :conditions => ["nimsp_candidate_id is not null"]
  scope :with_openstates_photo_url, :conditions => ["openstates_photo_url is not null"]
  scope :with_current_role, :include => :current_roles

  # How will we allow people to sort bills?
  SORTABLE_BY = {
    "First Name" => "first_name asc",
    "Last Name" => "last_name asc"
  }.freeze

  define_index do
    indexes first_name, middle_name, last_name, :sortable => true
    has email

    # Trigger the join on citations before indexing the count
    has citations(:id), :as => :citations_ids
    has "COUNT(citations.id)", :as => :citations_count, :type => :integer

    has chamber(:id), :as => :chamber_id, :facet => true
    has "current_district_order_for(people.id)", :as => :district_order, :type => :string
  end

  def full_name
    [first_name, last_name].join(' ').squeeze(' ').strip + (suffix? ? ', ' + suffix : '')
  end

  def gender_fm
    case gender
      when "M"
        "Male"
      when "F"
        "Female"
      else
        "Unknown"
    end
  end

  def gender_class
    "gender-" + gender_fm.parameterize
  end

  def current_role
    current_roles.try(:first)
  end

  def current_district_name
    Person.find_by_sql(["select current_district_name_for(?) as name", id]).try(:first).try(:name)
  end

  def official_name
    [chamber.try(:title), first_name, middle_name, last_name, suffix].join(' ').squeeze(' ').strip
  end

  def wiki_name
    normalized_names = [first_name, last_name].map { |name| name.mb_chars.normalize(:kd).gsub(/[^\-x00-\x7F]/n, '') }
    normalized_names.join(' ').gsub(' ', '_')
  end

  def youtube_url
    youtube_id.blank? ? nil : "http://www.youtube.com/user/" + youtube_id
  end

  def has_contributions?
    !(self.contributions | self.industry_contributions | self.business_contributions | self.sector_contributions).blank?
  end

  def photo_url(size = :full)
    openstates_photo_url || votesmart_photo_url
  end

  def current_sponsorship_vitals
    Person.find_by_sql(["
      select * from (
        select
        -- this is a subquery because we want the max() to look at all rows
        y.sponsor_id as id,
        y.session_id,
        y.bill_count,
        y.rank,
        -- we have to do a max() here because you can't do max(row_number() over ..)
        max(y.rnum) over (partition by y.session_id) as total_sponsors
        from (
          select s.sponsor_id, s.bill_count, s.session_id,
          -- rank may have duplicates (3 people with rank #3),
          -- row_number does not.
          row_number() over w as rnum,
          rank() over w as rank
          from
            (select b.session_id, s0.sponsor_id,
            -- we're doing this subquery for the bill_count.
            count(*) as bill_count
            from bill_sponsorships s0,
            bills b,
            v_most_recent_sessions s1
            where s0.bill_id = b.id
            and s1.id = b.session_id
            group by s0.sponsor_id, b.session_id) s
          window w as (partition by s.session_id order by s.bill_count desc)
        ) y
      ) z
      where z.id = ?
      limit 1", id]).first
  end

  def to_param
    "#{id}-#{full_name.parameterize}"
  end

  private

  def photo_url_provided?
    !self.photo_url.blank?
  end

  def download_remote_image
    self.photo = do_download_remote_image
    self.openstates_photo_url = photo_url
  end

  def do_download_remote_image
    return nil unless photo_url

    uri = URI.parse(photo_url)

    uri.open do |f|
      f.base_uri.path.split('/').blank? ? nil : f.read
    end

  rescue
    # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
  end

end
