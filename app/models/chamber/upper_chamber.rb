class UpperChamber < Chamber
  US_SENATE = find(:first, :conditions => {:legislature_id => Legislature::CONGRESS})
end
