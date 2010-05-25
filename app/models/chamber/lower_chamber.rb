class LowerChamber < Chamber
  US_HOUSE = find(:first, :conditions => {:legislature_id => Legislature::CONGRESS})
end
