class Sponsorship < ActiveRecord::Base
  belongs_to :bill
  belongs_to :sponsor, :class_name => "Person" 
end
