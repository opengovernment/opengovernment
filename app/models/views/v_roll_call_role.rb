class VRollCallRole < View
  belongs_to :roll_call
  belongs_to :role
  belongs_to :vote
  belongs_to :person
  belongs_to :district
  belongs_to :chamber
  belongs_to :session
end
