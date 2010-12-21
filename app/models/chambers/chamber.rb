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

#  has_and_belongs_to_many :people, :join_table => 'v_all_roles' do
#    def for_sessions(sessions)
#      where(["v_all_roles.session_id in (?)", sessions])
#    end
#    def democrats
#      where("v_all_roles.party = 'Democrat'")
#    end
#    def republicans
#      where("v_all_roles.party = 'Republican'")
#    end
#    def other
#      where("v_all_roles.party not in ('Democrat', 'Republican')")
#    end
#    def including_district_names
#      select('people.*, v_all_roles.district_name')
#    end
#  end
#
#  has_and_belongs_to_many :most_recent_people, :join_table => 'v_most_recent_roles' do
#    def democrats
#      where("v_most_recent_roles.party = 'Democrat'")
#    end
#    def republicans
#      where("v_most_recent_roles.party = 'Republican'")
#    end
#    def other
#      where("v_most_recent_roles.party not in ('Democrat', 'Republican')")
#    end
#    def including_district_names
#      select('people.*, v_most_recent_roles.district_name')
#    end
#  end
#
  def self.federal
    [LowerChamber.US_HOUSE, UpperChamber.US_SENATE]
  end

  # Using the state and districts associated with this chamber,
  # find all current legislators for a given point.
  def current_legislators_by_point(point)
    places = Place.by_point(point)
    places_and_people = []
    places.each do |place|
      if place.kind_of?(District) && place.chamber == self
        places_and_people << [place, place.current_legislators]
      elsif place.kind_of?(State) && self == ::UpperChamber::US_SENATE
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
  validates_numericality_of :term_length, :only_integer => true
end
