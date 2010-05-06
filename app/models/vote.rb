class Vote < ActiveRecord::Base
  belongs_to :bill
  belongs_to :chamber
  has_many :rolls
end
