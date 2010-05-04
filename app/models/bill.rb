class Bill < ActiveRecord::Base
  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  has_many :sponsorships
  has_many :sponsors, :through  => :sponsorships

  has_many :versions
  has_many :actions
end
