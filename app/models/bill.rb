class Bill < ActiveRecord::Base
  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  has_many :sponsorships
  has_many :sponsors, :through  => :sponsorships

  has_many :versions
  has_many :actions

  class << self
    def find_by_param(param)
      find_by_legislature_bill_id(param.titleize.upcase)
    end
  end

  def to_param
    legislature_bill_id.parameterize
  end
end
