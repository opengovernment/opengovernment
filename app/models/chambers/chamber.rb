class Chamber < ActiveRecord::Base
  belongs_to :legislature
  has_many :districts
  has_many :legislators, :through => :districts
  has_many :bills
  has_many :roles

  with_options :through => :legislature do |a|
    a.has_many :committees
    a.has_many :primary_committees
    a.has_many :sub_committees
    a.has_one :state
  end

  default_scope :order => "case when chambers.type = 'UpperChamber' then 0 else 1 end"

  has_and_belongs_to_many :people, :join_table => 'v_all_roles', :select => "distinct people.*"

  def self.federal
    [LowerChamber.us_house, UpperChamber.us_senate]
  end

  # Using the state and districts associated with this chamber,
  # find all current legislators for a given point.
  def current_legislators_by_point(point)
    places = Place.by_point(point)
    places_and_people = []
    places.each do |place|
      if place.kind_of?(District) && place.chamber == self
        places_and_people << [place, place.current_legislators]
      elsif place.kind_of?(State) && self == ::UpperChamber.us_senate
        places_and_people << [place, place.senators]
      end
    end
    places_and_people
  end

  def short_name
    case name
    when "House of Representatives", "House of Delegates"
      "House"
    else
      name
    end
  end

  validates_uniqueness_of :name, :scope => :legislature_id
  validates_uniqueness_of :type, :scope => :legislature_id
  validates_numericality_of :term_length, :only_integer => true, :allow_nil => true
end
