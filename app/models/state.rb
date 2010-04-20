class State < Place
  set_table_name 'states'

  has_many :districts
  named_scope :supported, :conditions => ["launch_date < ?", Time.now]
  named_scope :pending, :conditions => ["launch_date >= ?", Time.now]
  named_scope :unsupported, :conditions => {:launch_date => nil}

  # Which states are we importing data for?
  named_scope :loadable, :conditions => {:abbrev => ['CA', 'TX']}
  # this could be:
  # named_scope :loadable, :conditions => ["launch_date is not null"]
  
  validates_uniqueness_of :fips_code, :allow_nil => true
  validates_presence_of :name, :abbrev
  validates_inclusion_of :unicameral, :in => [true, false]

  def to_param
    [id.to_s, abbrev.downcase.parameterize].join('-')
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
end
