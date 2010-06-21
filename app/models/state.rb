class State < Place
  set_table_name 'states'

  has_many :districts
  has_many :addresses
  has_one :legislature
  with_options :through => :legislature do |hm|
    hm.has_many :committees
    hm.has_many :chambers
    hm.has_many :lower_committees
    hm.has_many :joint_committees
    hm.has_many :upper_committees
  end
  has_many :bills
  has_many :special_interest_groups

  scope :supported, :conditions => ["launch_date < ?", Time.now]
  scope :pending, :conditions => ["launch_date >= ?", Time.now]
  scope :unsupported, :conditions => {:launch_date => nil}
  has_many :current_senators, :through => :state_roles, :class_name => 'Person', :source => :person, :conditions => Role::CURRENT
  has_many :state_roles, :foreign_key => 'state_id', :class_name => 'Role'

  # Which states are we importing data for?
  scope :loadable, :conditions => {:abbrev => ['CA', 'TX']}
  # this could be:
  # scope :loadable, :conditions => ["launch_date is not null"]

  validates_uniqueness_of :fips_code, :allow_nil => true
  validates_presence_of :name, :abbrev
  validates_inclusion_of :unicameral, :in => [true, false]
  has_many :subscriptions

  class << self
    def find_by_param(param, ops = {})
      find_by_name(param.titleize, ops)
    end

    def find_by_slug(param, ops = {})
      find_by_param(param, ops)|| \
      find_by_name(param.capitalize, ops) || \
      find_by_abbrev(param.upcase, ops)
    end
  end

  def to_param
    "#{name.parameterize}"
  end

  def unsupported?
    launch_date.blank?
  end

  def supported?
    !unsupported? && (launch_date < Time.now)
  end

  def pending?
    !unsupported? && (launch_date >= Time.now)
  end

  def region_code
    "US-#{self.abbrev}"
  end
end
