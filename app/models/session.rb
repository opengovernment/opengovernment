class Session < ActiveRecord::Base
  belongs_to :legislature
  has_many :roles
  has_many :bills

  scope :active, :conditions => ["date_part('year', current_timestamp) between start_year and end_year"]
  scope :complete, :conditions => ["id in (select distinct session_id from roles)"]
  scope :most_recent, lambda { |legislature_id| complete.where(["legislature_id = ?", legislature_id]).order("end_year desc").limit(1) }

  validates_uniqueness_of :name, :scope => :legislature_id
  
  has_many :sub_sessions, :class_name => 'Session', :foreign_key => 'parent_id', :dependent => :destroy

  def to_param
    name.parameterize
  end
  
end
