class VMostRecentRole < View
  set_primary_key :role_id
  belongs_to :role
  belongs_to :person
  belongs_to :district
  belongs_to :chamber
  belongs_to :session
  belongs_to :state
end
