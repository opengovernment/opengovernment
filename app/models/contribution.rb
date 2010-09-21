class Contribution < ActiveRecord::Base
  belongs_to :person
  belongs_to :corporate_entity
  belongs_to :state, :foreign_key => 'contributor_state_id'

  define_index do
    indexes contributor_name, :sortable => true
    has state_id
  end
end
