class Legislature < ActiveRecord::Base
  has_one :upper_chamber
  has_one :lower_chamber
  has_many :chambers
  has_many :committees
  has_many :lower_committees
  has_many :upper_committees
  has_many :joint_committees
  belongs_to :state
  validates_uniqueness_of :name
  validates_presence_of :name

  has_many :sessions, :conditions => {:parent_id => nil} 

  CONGRESS = Legislature.find_by_name("United States Congress")
  MAJOR_PARTIES = ["Democrat", "Republican"]
end
