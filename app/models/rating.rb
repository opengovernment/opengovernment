class Rating < ActiveRecord::Base
  belongs_to :person
  belongs_to :special_interest_group, :foreign_key => 'sig_id'
  has_one :category, :through => :special_interest_group
end
