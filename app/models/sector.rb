class Sector < CorporateEntity
  def total_contributions
    self.children.joins(:contributions).sum("amount")
  end
end
