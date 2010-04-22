class District < Place
  set_table_name 'districts'

  belongs_to :state
  belongs_to :chamber
  validates_presence_of :state_id, :name
  named_scope :numbered, lambda { |n| { :conditions => ["trim(leading '0' from census_sld) = ?", n] } }
  named_scope :by_x_y, lambda { |lat, lng| { :conditions => ["ST_Contains(geom, ST_GeomFromText('POINT(? ?)', ?))", lng, lat, SRID] } }
  has_many :district_roles, :foreign_key => 'district_id', :class_name => 'Role'
  has_many :representatives, :through => :district_roles, :class_name => 'Person', :source => :person

  # The geographic SRID used for all Census bureau data
  SRID = 4269.freeze

  def number
    census_sld.sub! /\A0+/, ''
  end

  class << self
    # This returns the point object (GeoLoc)
    # and the districts associated with that point,
    # or nil if nothing was found.
    def find_by_address(addr)
      point = GeoKit::Geocoders::MultiGeocoder.geocode(addr)
      return nil unless point.success?
      [point, self.by_x_y(point.lat, point.lng)]
    end
  end
end
