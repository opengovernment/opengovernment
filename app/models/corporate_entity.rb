class CorporateEntity < ActiveRecord::Base
  # This is an STI base class; do not instantiate.
  has_many :contributions
  has_ancestry
end