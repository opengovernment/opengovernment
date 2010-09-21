class Industry < CorporateEntity
  belongs_to :sector
  has_many :businesses
  scope :with_contribution_amounts, joins(:businesses => :contributions).select("corporate_entities.id, corporate_entities.name, sum(contributions.amount) as amount").group("corporate_entities.id, corporate_entities.name")
  scope :contributions_for_state, lambda { |id| with_contribution_amounts.where(["contributions.state_id = ?", id]) }

end
