class RollCall < ActiveRecord::Base
  belongs_to :vote
  belongs_to :person
end
