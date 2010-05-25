class LowerChamber < Chamber
  US_HOUSE = find(:first, :conditions => {:legislature_id => Legislature::CONGRESS})
  has_many :committees, :through => :legislature, :conditions => {:type => "LowerCommittee"}

end
