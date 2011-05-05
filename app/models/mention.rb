class Mention < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  scope :since, lambda { |d| where(["mentions.date > ?", d]) }

  def as_json(opts = {})
    default_opts = {:except => [:owner_id, :owner_type]}
    super(default_opts.merge(opts))
  end
end
