class LowerChamber < Chamber

  with_options :through => :legislature, :conditions => {:type => 'LowerCommittee'} do |a|
    a.has_many :committees
    a.has_many :primary_committees
    a.has_many :sub_committees
  end

  def self.us_house
    find(:first, :conditions => {:legislature_id => Legislature.congress})
  end

end
