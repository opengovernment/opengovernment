class Action < ActiveRecord::Base
  belongs_to :bill
  belongs_to :actor, :polymorphic => true
end
