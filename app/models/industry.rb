class Industry < CorporateEntity
  belongs_to :sector
  has_many :businesses
  has_many :contributions, :through => :businesses do
    def for_state(state_id)
      where(:state_id => state_id)
    end
  end

  scope :with_contribution_amounts, joins(:businesses => :contributions).select("corporate_entities.id, corporate_entities.name, sum(contributions.amount) as amount").group("corporate_entities.id, corporate_entities.name")
  scope :aggregates_for_state, lambda { |id| with_contribution_amounts.where(["contributions.state_id = ?", id]) }
  scope :aggregates_for_person, lambda { |id| with_contribution_amounts.where(["contributions.person_id = ?", id]) }
  
  def to_param
    "#{id} #{name}".parameterize
  end
end
