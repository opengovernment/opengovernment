class CommitteeMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :session
  belongs_to :committee
  
  default_scope :order => "case when role = 'member' then 5 when role = 'vice chair' then 4 when role = 'chair' then 0 when role = 'chairman' then 0 else 1 end"
end
