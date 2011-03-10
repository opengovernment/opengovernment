class Place < ActiveRecord::Base
  self.abstract_class = true

  def self.by_point(point)
    [State.find_by_abbrev(point.state)] | District.for_x_y(point.lat, point.lng)
  end
  
  def self.by_x_y(lat, lng)
    result = [StateBoundary.for_x_y(lat, lng).first.try(:state)] | District.for_x_y(lat, lng)

    result.compact
  end

end
