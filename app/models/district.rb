class District < ActiveRecord::Base
  belongs_to :state
  belongs_to :district_type
  validates_presence_of :state_id
  validates_presence_of :district_type_id
  validates_presence_of :name

  class << self
    def find_by_x_y(lat, lng)
      find_by_sql(["select d.* from districts d where ST_Contains(geom, ST_GeomFromText('POINT(? ?)', -1))", lng, lat]);
    end

    def find_by_address(addr)
      point = GeoKit::Geocoders::MultiGeocoder.geocode(addr)
      return nil unless point.success?
      self.find_by_x_y(point.lat, point.lng)
    end
  end
end
