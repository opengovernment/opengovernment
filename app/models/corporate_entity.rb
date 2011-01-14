class CorporateEntity < ActiveRecord::Base
  set_primary_key :transparencydata_code
  # This is an STI base class; do not instantiate.
end