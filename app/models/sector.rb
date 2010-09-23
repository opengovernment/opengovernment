class Sector < CorporateEntity
  has_many :industries
  scope :with_contribution_amounts, joins(:industries => {:businesses => :contributions}).select("corporate_entities.id, corporate_entities.name, sum(contributions.amount) as amount").group("corporate_entities.id, corporate_entities.name")
  scope :aggregates_for_state, lambda { |id| with_contribution_amounts.where(["contributions.state_id = ?", id]) }
  scope :aggregates_for_person, lambda { |id| with_contribution_amounts.where(["contributions.person_id = ?", id]) }

end
