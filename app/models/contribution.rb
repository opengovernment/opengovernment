class Contribution < ActiveRecord::Base
  belongs_to :person
  belongs_to :corporate_entity

  define_index do
    indexes contributor_name, :sortable => true
  end
end
