class Category < ActiveRecord::Base
  has_many :special_interest_groups

  acts_as_taggable
  acts_as_taggable_on :issues
end
