class Contribution < ActiveRecord::Base
  belongs_to :candidate, :class_name => "Person"
end
