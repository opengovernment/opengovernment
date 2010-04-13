class State < ActiveRecord::Base
  has_many :districts
  named_scope :supported, :conditions => ["launch_date < ?", Time.now]
  named_scope :pending, :conditions => ["launch_date >= ?", Time.now]
  named_scope :unsupported, :conditions => {:launch_date => nil}
  validates_uniqueness_of :fips_code, :allow_nil => true
  
  def to_param
    [id.to_s, abbrev.downcase].join('-')
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
