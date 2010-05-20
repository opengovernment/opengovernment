class CommitteeMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :session
  belongs_to :committee
end
