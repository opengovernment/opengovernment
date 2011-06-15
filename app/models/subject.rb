class Subject < ActiveRecord::Base
  has_many :bills_subjects, :dependent => :destroy
  has_many :bills, :through => :bills_subjects
  
  scope :for_state, lambda { |s| joins(:bills).where(["bills.state_id = ?", s]) }
  scope :for_sessions, lambda { |s| joins(:bills).where(["bills.session_id in (?)", s]) }

  scope :with_bill_count, { :select => 'subjects.*, count(bills.id) as bill_count', :joins => :bills, :group => 'subjects.id, subjects.name, subjects.code, subjects.created_at, subjects.updated_at' }

  def self.with_session_bill_count(session_ids, ops = {})
    ops[:limit] ||= 1000
    ops[:order] ||= :name

    order_sql = case ops[:order]
    when :popularity
      'bill_count desc'
    when :name
      's.name'
    else
      's.name'
    end
  
    find_by_sql(["select s.*, coalesce(bsa.bill_count, 0) as bill_count from subjects s left outer join (select subject_id, count(bill_id) as bill_count from bills_subjects bs join bills b on (bs.bill_id = b.id) where b.session_id in (?) group by subject_id) bsa on (s.id = bsa.subject_id) order by #{order_sql} limit ?", session_ids, ops[:limit]])
  end

  acts_as_taggable
  acts_as_taggable_on :issues
end
