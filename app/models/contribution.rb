class Contribution < ActiveRecord::Base
  belongs_to :person
  belongs_to :corporate_entity
  belongs_to :state, :foreign_key => 'contributor_state_id'
  scope :grouped_by_name, select("contributions.contributor_name, sum(contributions.amount) as amount").group("contributions.contributor_name").order("amount desc")
  scope :grouped_by_recipient, select("contributions.person_id, sum(contributions.amount) as amount").group("contributions.person_id").order("amount desc").includes(:person)

  define_index do
    indexes contributor_name, :sortable => true
    has state_id
  end
end
