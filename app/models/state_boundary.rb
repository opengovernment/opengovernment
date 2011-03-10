class StateBoundary < Place
  belongs_to :state

  # TODO: This could be DRYed up and somehow composed with district.rb...

  # The geographic SRID used for all Census bureau data
  SRID = 4269.freeze

  scope :for_x_y, lambda { |lat, lng| { :conditions => ["ST_Contains(geom, ST_GeomFromText('POINT(? ?)', ?))", lng, lat, SRID] } }

end
