class Business < ActiveRecord::Base
  has_many :contributions
  has_ancestry
end
