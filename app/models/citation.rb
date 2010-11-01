class Citation < ActiveRecord::Base
  belongs_to :citeable, :polymorphic => true
end
