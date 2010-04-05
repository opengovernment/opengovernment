class DistrictType < ActiveRecord::Base
  has_many :districts
  validates_presence_of :name, :description
  validates_length_of :name, :maximum => 2

  C1 = DistrictType.find_by_name('C1')
  C2 = DistrictType.find_by_name('C2')
  C3 = DistrictType.find_by_name('C3')
  C4 = DistrictType.find_by_name('C4')
  LL = DistrictType.find_by_name('LL')
  LU = DistrictType.find_by_name('LU')
end
