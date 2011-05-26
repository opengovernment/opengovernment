class Role < ActiveRecord::Base
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

  validates_presence_of :state, :if => 'district.nil?'
  validates_presence_of :district, :if => 'state.nil?'

  scope :on_date, lambda { |date| {
          :select => 'roles.*',
          :joins => 'inner join v_most_recent_roles vr on vr.role_id = roles.id',
          :conditions => ['? between vr.start_date and vr.end_date', date]
        } }
  scope :for_chamber, lambda { |c| { :conditions => {:chamber_id => c} } }
  scope :for_session, lambda { |s| {:conditions => {:session_id => s} } }
  scope :for_state, lambda { |s| { :conditions => ['roles.district_id in (select id from districts where state_id = ?) or roles.state_id = ?', s, s] } }
  scope :democrats, where("party in ('Democrat','Democratic','Democratic-Farmer-Labor')")
  scope :republicans, where("party = 'Republican'")
  scope :others, where("party not in ('Democrat','Republican','Democratic','Democratic-Farmer-Labor')")
  scope :current, on_date(Date.today)
  scope :by_last_name, joins(:person).order('people.last_name')

  def self.current_chamber_roles(chamber)
    current.for_chamber(chamber).scoped({:include => [:district, :chamber, :person], :order => 'people.first_name'})
  end

  def current?
    Role.count_by_sql(['select count(*) from v_most_recent_roles where role_id = ? and current_date between start_date and end_date', id])
  end

  def party_abbr
    if party.blank?
      return "ind"
    end

    case party
    when "Democrat", "Democratic"
      "dem"
    when "Republican"
      "rep"
    when "Democratic-Farmer-Labor"
      "dfl"
    when "Independent"
      "ind"
    end
  end

  def party_fm
    Role.party_fm(party)
  end

  def self.party_fm(party)
    nil if party.blank?

    case party
      when "Democrat", "Democratic"
        "D"
      when "Democratic-Farmer-Labor"
        "DFL"
      when "Republican"
        "R"
      else
        "I"
    end
  end

  def party_adj
    Role.party_adj(party)
  end

  def self.party_adj(party)
    nil if party.blank?

    case party
      when "Democrat", "Democratic"
        "Democrat"
      when "Democratic-Farmer-Labor"
        "Democratic-Farmer-Laborer"
      else
        party
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
    return unless start_date && end_date

    if start_date < end_date
      return true
    else
      return false
    end
  end
end
