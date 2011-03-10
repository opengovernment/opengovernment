class District < Place
  set_table_name 'districts'

  belongs_to :state
  belongs_to :chamber
  validates_presence_of :state_id, :name

  scope :numbered, lambda { |n| { :conditions => ["trim(leading '0' from census_sld) = ?", n.gsub(/^0+/, '')] } }
  scope :for_x_y, lambda { |lat, lng| { :conditions => ["ST_Contains(geom, ST_GeomFromText('POINT(? ?)', ?))", lng, lat, SRID] } }
  scope :for_state, lambda { |n| { :conditions => ['state_id = ?', n] } }
  
  # This will force a numeric sort on the district number!
  scope :by_number, :order => %q{CASE WHEN census_sld < 'A' 
         THEN lpad(census_sld, 3, '0')
         ELSE census_sld END}

  has_and_belongs_to_many :roles, :join_table => 'v_most_recent_roles'
  has_many :legislators, :through => :roles, :class_name => 'Person', :source => :person
  has_and_belongs_to_many :legislators, :join_table => 'v_most_recent_roles', :class_name => 'Person', :conditions => 'current_date between v_most_recent_roles.start_date and v_most_recent_roles.end_date'

  # The geographic SRID used for all Census bureau data
  SRID = 4269.freeze

  def number
    census_sld.sub /\A0+/, ''
  end

  def full_name
    "#{state.name} #{chamber.name} District #{number}"
  end

  def description
    "This is #{state.name}'s #{chamber.name.downcase} District #{number}."
  end

  def as_json(opts = {})
    opts ||= {:except => [:geom]}
    super(opts)
  end

  # This returns the point object (GeoLoc)
  # and the districts associated with that point,
  # or nil if nothing was found.
  def self.find_by_address(addr)
    point = GeoKit::Geocoders::MultiGeocoder.geocode(addr)
    return nil unless point.success?
    [point, District.for_x_y(point.lat, point.lng)]
  end
end
