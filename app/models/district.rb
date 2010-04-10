class District < ActiveRecord::Base
  belongs_to :state
  belongs_to :district_type
  validates_presence_of :state_id
  validates_presence_of :district_type_id
  validates_presence_of :name
  
  # The geographic SRID used for all Census bureau data
  SRID = 4269

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
