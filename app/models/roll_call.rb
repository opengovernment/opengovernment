class RollCall < ActiveRecord::Base
  belongs_to :vote
  belongs_to :person, :foreign_key => "leg_id"
end
