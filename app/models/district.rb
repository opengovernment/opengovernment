class District < ActiveRecord::Base
  belongs_to :state
  belongs_to :district_type
  validates_presence_of :state_id
  validates_presence_of :district_type_id
  validates_presence_of :name
end
