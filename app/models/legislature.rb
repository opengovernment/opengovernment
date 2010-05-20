class Legislature < ActiveRecord::Base
  has_one :upper_chamber
  has_one :lower_chamber
  has_many :chambers
  has_many :committees
  belongs_to :state
  validates_uniqueness_of :name
  validates_presence_of :name

  has_many :sessions
  CONGRESS = Legislature.find_by_name("United States Congress")
end
