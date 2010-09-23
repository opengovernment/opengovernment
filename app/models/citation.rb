class Citation < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  scope :since, lambda { |d| where(["citations.date > ?", d]) }

end
