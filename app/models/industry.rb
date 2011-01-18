class Industry < ActiveRecord::Base
  set_primary_key :transparencydata_code

  # Notes on this model:
  # The transparencydata_code is a code that follows the format /[A-Z]\d{4}/.
  # The letter corresponds roughly to an economic sector, and the
  # numeric part is a hierarchy of industries for the sector.
  # So A0000 is the top level ("AGRICULTURE"),
  # A1000 is the secondary level ("CROP PRODUCTION & BASIC PROCESSING"),
  # and A1100 is the tertiary level ("COTTON").
  
  # Contributions can be attached at any level.

  has_many :contributions do
    def for_state(state_id)
      where(:state_id => state_id)
    end
  end

  scope :with_contribution_amounts, joins(:contributions).select("industries.transparencydata_code, industries.name, sum(contributions.amount) as amount").group("industries.transparencydata_code, industries.name")
  scope :aggregates_for_state, lambda { |id| with_contribution_amounts.where(["contributions.state_id = ?", id]) }
  scope :aggregates_for_person, lambda { |id| with_contribution_amounts.where(["contributions.person_id = ?", id]) }

  def to_param
    "#{id} #{name}".parameterize
  end

end
