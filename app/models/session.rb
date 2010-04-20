class Session < ActiveRecord::Base
  belongs_to :legislature
  has_many :roles
end
