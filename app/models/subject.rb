class Subject < ActiveRecord::Base
  has_many :bills_subjects
  has_many :bills, :through => :bills_subjects
  
  scope :for_state, lambda { |s| joins(:bills).where(["bills.state_id = ?", s]) }

  scope :with_bill_count, { :select => 'subjects.*, count(bills.id) as bill_count', :joins => :bills, :group => 'subjects.id, subjects.name, subjects.code, subjects.created_at, subjects.updated_at' }

  acts_as_taggable
  acts_as_taggable_on :issues
end
