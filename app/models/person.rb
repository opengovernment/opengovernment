require 'open-uri'

class Person < ActiveRecord::Base
  include Trackable

  # See http://www.taknado.com/en/2009/10/01/paperclip-tweaks/
  # and http://www.imagemagick.org/script/command-line-processing.php#geometry
  # for geometry options
  has_attached_file :photo, :styles => {:full => '90', :thumb => '50x50#'}, :convert_options => { :all => '-gravity north'}

  acts_as_noteworthy :with => [:official_name]

  validates_inclusion_of :gender, :in => %w(M F), :allow_blank => true
  validates_presence_of :first_name, :last_name

  [:website_one, :website_two, :webmail].each do |prop|
    validates_format_of prop, :with => URI::regexp(%w(http https)), :allow_nil => true
  end

  before_update :queue_photo_download, :if => :refresh_photo?
  after_create :queue_photo_download

  has_many :roles, :dependent => :destroy
  has_many :addresses, :dependent => :destroy do
    def in_district
      where("addresses.votesmart_type = 'District'")
    end
  end
  has_many :committee_memberships, :dependent => :destroy
  has_many :committees, :through => :committee_memberships

  has_and_belongs_to_many :current_roles, :join_table => "v_most_recent_roles", :class_name => 'Role'
  has_one :chamber, :through => :roles

  has_many :citations, :as => :citeable
  has_many :bill_sponsorships, :foreign_key => "sponsor_id"
  has_many :sponsored_bills, :class_name => 'Bill', :through => :bill_sponsorships, :source => :bill

  has_many :contributions, :order => "amount desc", :limit => 20
  has_many :ratings, :order => "timespan desc" do
    def for_category(category)
      joins(:special_interest_group).where(["special_interest_groups.category_id = ?", category.id])
    end
  end

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

  scope :with_votesmart_id, :conditions => ['votesmart_id is not null']
  scope :with_transparencydata_id, :conditions => ['transparencydata_id is not null']
  scope :with_photo_url, :conditions => ['photo_url is not null']
  scope :with_current_role, :include => :current_roles

  # How will we allow people to sort people?
  SORTABLE_BY = {
    'First Name' => 'first_name asc',
    'Last Name' => 'last_name asc'
  }.freeze

  define_index do
    indexes first_name, middle_name, last_name, :sortable => true

    has email
    has roles(:session_id), :as => :session_ids, :facet => true
    has roles(:chamber_id), :as => :chamber_ids, :facet => true

    # Trigger the join on mentions before indexing the count
    has mentions(:id), :as => :mentions_ids
    has 'COUNT(mentions.id)', :as => :mentions_count, :type => :integer

    has 'current_district_order_for(people.id)', :as => :district_order, :type => :string
    has 'current_state_for(people.id)', :as => :state_id, :type => :integer
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

  def district_office_city
    addresses.in_district.first.try(:city)
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
  
  def wikipedia_url
    'http://en.wikipedia.org/wiki/' + wiki_name
  end

  def opencongress_url
    govtrack_id.blank? ? nil : 'http://www.opencongress.org/people/show/' + govtrack_id.to_s
  end

  def youtube_url
    youtube_id.blank? ? nil : 'http://www.youtube.com/user/' + youtube_id
  end

  def state_id
    current_roles.try(:first).try(:state_id)
  end
 
  def state
   state_id ? State.find(state_id) : nil
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

  def sync_photo!
    self.photo = do_download_remote_image
    self.save(false)
  end

  def refresh_photo?
    !self.photo_url.blank? && (self.photo_url_changed? || !self.photo?)
  end

  private

  def queue_photo_download
    Delayed::Job.enqueue PersonPhotoJob.new(self.id)
  end

  def do_download_remote_image
    io = open(URI.parse(photo_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue OpenURI::HTTPError => e
    # eg. 404
    puts "OpenURL error: #{e}"
    raise
  rescue SystemCallError => e
    # eg. connection reset by peer
    puts "System call error: #{e}"
    raise
  end

end
