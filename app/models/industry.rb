class Industry < CorporateEntity
  # Notes on this model:
  # The transparencydata_code is a code that follows the format /[A-Z]\d{4}/.
  # The letter corresponds roughly to an economic sector, and the
  # numeric part is a hierarchy of industries for the sector.
  # So A0000 is the top level ("AGRICULTURE"),
  # A1000 is the secondary level ("CROP PRODUCTION & BASIC PROCESSING"),
  # and A1100 is the tertiary level ("COTTON").
  
  has_many :businesses
  has_many :contributions, :through => :businesses do
    def for_state(state_id)
      where(:state_id => state_id)
    end
  end

  scope :with_contribution_amounts, joins(:businesses => :contributions).select("corporate_entities.transparencydata_code, corporate_entities.name, sum(contributions.amount) as amount").group("corporate_entities.transparencydata_code, corporate_entities.name")
  scope :aggregates_for_state, lambda { |id| with_contribution_amounts.where(["contributions.state_id = ?", id]) }
  scope :aggregates_for_person, lambda { |id| with_contribution_amounts.where(["contributions.person_id = ?", id]) }

  def to_param
    "#{id} #{name}".parameterize
  end
end
