class Subject < ActiveRecord::Base
  has_many :bills_subjects
  has_many :bills, :through => :bills_subjects
  
  scope :for_state, lambda { |s| where(["subjects.id in (select bs.subject_id from bills_subjects bs, bills where bills.id = bs.bill_id and bills.state_id = ?)", s]) }
  
  scope :with_bill_count, { :select => 'subjects.*, count(bills_subjects.id) as bill_count', :joins => 'left outer join bills_subjects on bills_subjects.subject_id = subjects.id', :group => 'subjects.id, subjects.name, subjects.code, subjects.created_at, subjects.updated_at' }
  
  acts_as_taggable
  acts_as_taggable_on :issues
end
