class Rating < ActiveRecord::Base
  belongs_to :person
  belongs_to :special_interest_group, :foreign_key => 'sig_id'
end
