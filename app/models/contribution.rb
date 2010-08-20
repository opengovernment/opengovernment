class Contribution < ActiveRecord::Base
  belongs_to :candidate, :class_name => 'Person'
  belongs_to :business

  define_index do
    indexes contributor_name, :sortable => true
  end

end
