class Issue < ActiveRecord::Base
  has_many :special_interest_groups
end
