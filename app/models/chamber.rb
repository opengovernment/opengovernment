class Chamber < ActiveRecord::Base
  belongs_to :legislature
  has_many :districts
  has_many :current_legislators, :through => :districts
  has_one :state, :through => :legislature
  has_many :bills

  # Using the state and districts associated with this chamber,
  # find all current legislators for a given point.
  def current_legislators_by_point(point)
    places = Place.by_point(point)
    places_and_people = []
    places.each do |place|
      if place.kind_of?(District) && place.chamber == self
        places_and_people << [place, place.current_legislators]
      elsif place.kind_of?(State) && self == UpperChamber::US_SENATE
        places_and_people << [place, place.current_senators]
      end
    end
    places_and_people
  end

  validates_uniqueness_of :name, :scope => :legislature_id
  validates_uniqueness_of :type, :scope => :legislature_id
  validates_numericality_of :term_length, :only_integer => true
end
