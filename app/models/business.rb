class Business < CorporateEntity
  def total_contributions
    self.contributions.sum("amount")
  end
end
