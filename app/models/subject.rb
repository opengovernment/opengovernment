class Subject < ActiveRecord::Base
  has_many :bills_subjects
  has_many :bills, :through => :bills_subjects
  
  scope :for_state, lambda { |s| joins(:bills).where(["bills.state_id = ?", s]) }
  scope :for_sessions, lambda { |s| joins(:bills).where(["bills.session_id in (?)", s]) }

  scope :with_bill_count, { :select => 'subjects.*, count(bills.id) as bill_count', :joins => :bills, :group => 'subjects.id, subjects.name, subjects.code, subjects.created_at, subjects.updated_at' }

  def self.with_session_bill_count(session_ids)
    find_by_sql(['select subjects.*, coalesce(ba.bill_count, 0) as bill_count from subjects left outer join (select bs.subject_id, count(b.id) as bill_count from bills_subjects bs, bills b where bs.bill_id = b.id and b.session_id in (?) group by bs.subject_id) ba on subjects.id = ba.subject_id order by subjects.name', session_ids])
  end

  acts_as_taggable
  acts_as_taggable_on :issues
end
