class Address < ActiveRecord::Base
  belongs_to :person
  belongs_to :state

  validates_presence_of :line_one, :person_id, :city, :postal_code
end