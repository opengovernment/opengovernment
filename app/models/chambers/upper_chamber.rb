class UpperChamber < Chamber
  US_SENATE = find(:first, :conditions => {:legislature_id => Legislature::CONGRESS})
  has_many :committees, :through => :legislature, :conditions => {:type => "UpperCommittee"}

end
