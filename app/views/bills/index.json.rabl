collection @bills

attributes :title, :short_title, :bill_number, :votesmart_id, :votesmart_key_vote
attributes :created_at, :last_action_at
attributes :state_id, :id, :chamber_id, :openstates_id
attributes :views, :permalink, :to_param, :kinds, :other_titles

code(:views_last_month) { |bill| bill.views(1.month.ago.utc) }

# --- Child objects ---

child(:session) {
  attributes :to_param, :start_year, :end_year, :id, :legislature_id, :parent_id
  attributes :name_fm => :name, :name => :original_name
}
child(:documents => :documents) { extends "documents/document" }
child(:versions => :versions) { extends "documents/document" }

child(:subjects => :subjects) { attributes :name, :code }

child(:votes) {
  attributes :kind, :motion, :chamber_id, :committee_name, :threshold, :date, :openstates_id
  attributes :yes_count, :no_count, :other_count, :paseed
  code(:permalink) { |vote| vote_path(vote) }
}
child(:actions) {
  attributes :actor, :action_number, :kinds
  attributes :created_at, :updated_at
}
child(:sponsorships => :sponsorships) {
  attributes :kind, :created_at, :updated_at, :sponsor_name
  attributes :sponsor_id => :person_id
} 
child(:citations) {
  attributes :url
}
