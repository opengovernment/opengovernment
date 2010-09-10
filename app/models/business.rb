class Business < ActiveRecord::Base
  has_many :contributions
  has_ancestry

  def total_contributions
    self.contributions.sum("amount")
  end
end
