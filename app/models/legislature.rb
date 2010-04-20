class Legislature < ActiveRecord::Base
  has_many :chambers
  belongs_to :state
  validates_uniqueness_of :name
  validates_presence_of :name

  CONGRESS = Legislature.find_by_name("United States Congress")
end
