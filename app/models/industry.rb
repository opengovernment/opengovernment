class Industry < CorporateEntity
  belongs_to :sector
  has_many :businesses
end
