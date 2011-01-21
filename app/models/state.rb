class State < Place
  set_table_name 'states'

  has_many :districts
  has_many :addresses
  has_one :legislature

  with_options :through => :legislature do |hm|
    hm.has_many :sessions
    hm.has_many :committees
    hm.has_many :chambers
    hm.has_one :upper_chamber
    hm.has_one :lower_chamber
    hm.has_many :lower_committees
    hm.has_many :joint_committees
    hm.has_many :upper_committees
    hm.has_many :primary_committees
    hm.has_many :sub_committees
  end

  has_many :bills
  has_many :special_interest_groups

  scope :supported, :conditions => ['launch_date < ?', Time.now]
  scope :pending, :conditions => ['launch_date >= ?', Time.now]
  scope :unsupported, :conditions => {:launch_date => nil}

  has_many :state_roles, :foreign_key => 'state_id', :class_name => 'Role'

  has_and_belongs_to_many :senators, :join_table => 'v_most_recent_roles', :conditions => 'district_id is null', :class_name => 'Person'

  has_and_belongs_to_many :us_rep_roles, :join_table => 'v_most_recent_roles', :conditions => ['v_most_recent_roles.chamber_id = ?', LowerChamber::US_HOUSE], :class_name => 'Role', :include => [:person]

  # For which states are we importing data?
  scope :loadable, :conditions => ['launch_date is not null'], :order => 'name'

  validates_uniqueness_of :fips_code, :allow_nil => true
  validates_presence_of :name, :abbrev
  validates_inclusion_of :unicameral, :in => [true, false]
  validates_format_of :official_url, :with => URI::regexp(%w(http)), :allow_nil => true

  has_many :subscriptions

  def self.find_by_param(param, ops = {})
    find_by_name(param.titleize, ops)
  end

  def self.find_by_slug(param, ops = {})
    find_by_param(param, ops)|| \
    find_by_name(param.capitalize, ops) || \
    find_by_abbrev(param.upcase, ops)
  end

  def to_param
    "#{name.parameterize}"
  end

  def bbox
    # We get a result back that looks something like this:
    # => "BOX(-106.645646 25.837377,-93.5164072637683 36.500704)"
    # So we need to simply turn this into a bounding box array and return that.

    if bbox_text = District.first(:select => 'st_extent(geom) as geo', :group => 'state_id', :conditions => {:state_id => id}).geo
      if md = bbox_text.match(%r{BOX\(([^\)]*)\)})
        return md[1].split(/,| /).collect {|x| x.to_f}
      end
    end
    nil
  end

  def bbox_aspect_ratio
    y = bbox
    (y[3]-y[1])/(y[2]-y[0])
  end

  def unsupported?
    launch_date.blank?
  end

  def supported?
    !unsupported? && (launch_date < Time.now)
  end

  def pending?
    !unsupported? && (launch_date >= Time.now)
  end

end
