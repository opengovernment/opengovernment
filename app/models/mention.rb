class Mention < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  scope :since, lambda { |d| where(["mentions.date > ?", d]) }

  def as_json(opts = {})
    super(opts.merge(:except => [:owner_id, :owner_type]))
  end
end
