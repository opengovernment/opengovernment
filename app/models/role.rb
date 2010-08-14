class Role < ActiveRecord::Base
  CURRENT = ["current_date between roles.start_date and roles.end_date"].freeze

  belongs_to :person
  belongs_to :chamber

  # One of state or district is always available, see #place
  belongs_to :state
  belongs_to :district

  # There is not always an associated session. It's there for Open States data but not GovTrack.
  # And anyway, people don't get elected to sessions--they get elected to chambers.
  belongs_to :session

  before_save :assure_dates_in_order

  validates_numericality_of :senate_class, :only_integer => true, :allow_blank => true, :in => [1...3]

  validates_presence_of :state, :if => "district.nil?"
  validates_presence_of :district, :if => "state.nil?"

  scope :current, :conditions => Role::CURRENT
  scope :on_date, lambda { |date| { :conditions => ["? between roles.start_date and roles.end_date", date] } }
  scope :for_chamber, lambda { |c| { :conditions => {:chamber_id => c} } }
  scope :for_state, lambda { |s| { :conditions => ["district_id in (select id from districts where state_id = ?) or state_id = ?", s, s] } }

  def self.current_chamber_roles(chamber)
    current.for_chamber(chamber).scoped({:include => [:district, :chamber, :person], :order => "people.first_name"})
  end

  def current?
    self.start_date < Date.today && Date.today < self.end_date
  end



  def party_abbr
    if party.blank?
      return "ind"
    end

    case party
    when "Democrat"
      "dem"
    when "Republican"
      "rep"
    else
      "ind"
    end
  end
  
  def party_fm
    case party
      when "Democrat"
        "D"
      when "Republican"
        "R"
      when ""
        ""
      else
        "I"
    end
  end

  def district_fm
    district.try(:number)
  end

  def affiliation_fm
    if !party_fm.blank?
      "#{party_fm}#{district.try(:number).try(:insert, 0, '-')}"
    else
      nil
    end
  end

  def place
    # for a given class, returns the appropriate symbol
    # to pass to the ActiveRecord method reflect_on_association
    def reflection_symbol(klass)
      klass.to_s.split("::").last.underscore.to_sym
    end

    # for all subclasses of the given base class, returns a
    # list of defined associations within the current class
    def association_methods(mti_base_class)
      Object.subclasses_of(mti_base_class).collect{|p|
        assoc = self.class.reflect_on_association(reflection_symbol(p))
        assoc ? assoc.name : nil
      }.compact
    end

    # invoke each association method and return the first
    # that is not null
    association_methods(Place).collect{|a|
      self.send a
    }.inject do |a, b|
      a || b
    end
  end

  def place=(p)
    def reflection_symbol(klass)
      klass.to_s.split("::").last.underscore.to_sym
    end

    def reflection_assignment_method(klass)
      Role.reflect_on_association(reflection_symbol(klass.class)).name.to_s + "="
    end

    self.send reflection_assignment_method(p.class), p
  end

  protected

  def assure_dates_in_order
    if !self.end_date.blank?
      false unless (self.start_date < self.end_date)
    end
  end
end
