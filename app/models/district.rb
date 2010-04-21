class District < Place
  set_table_name 'districts'

  belongs_to :state
  belongs_to :chamber
  validates_presence_of :state_id, :name
  named_scope :numbered, lambda { |n| { :conditions => ["trim(leading '0' from census_sld) = ?", n] } }

  # The geographic SRID used for all Census bureau data
  SRID = 4269.freeze

  def number
    census_sld.sub! /\A0+/, ''
  end

  class << self
    def find_by_x_y(lat, lng)
      find_by_sql(["select d.* from districts d where ST_Contains(geom, ST_GeomFromText('POINT(? ?)', ?))", lng, lat, SRID]);
    end

    # This returns the point object (GeoLoc)
    # and the districts associated with that point,
    # or nil if nothing was found.
    def find_by_address(addr)
      point = GeoKit::Geocoders::MultiGeocoder.geocode(addr)
      return nil unless point.success?
      [point, self.find_by_x_y(point.lat, point.lng)]
    end
  end
end
