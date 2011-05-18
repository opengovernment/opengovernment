class KeyVote < ActiveRecord::Base
  belongs_to :bill
  default_scope :order => 'votesmart_action_id desc'
end