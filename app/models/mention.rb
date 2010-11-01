class Mention < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  scope :since, lambda { |d| where(["mentions.date > ?", d]) }

end
