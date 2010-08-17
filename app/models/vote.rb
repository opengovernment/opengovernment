class Vote < ActiveRecord::Base
  belongs_to :bill
  belongs_to :chamber
  has_many :roll_calls, :dependent => :destroy

  def roll_calls_by_vote_type
    roll_calls = RollCall.where(:vote_id => id).order("case roll_calls.vote_type when 'yes' then 0 when 'no' then 1 when 'other' then 2 end, people.last_name").joins(:person).includes(:roles)
    roll_calls.group_by(&:vote_type)
  end

  def outcome_class
    passed ? "vote-passed" : "vote-failed"
  end
  
  def total_count
    yes_count + no_count + other_count
  end

  # yes_frac / no_frac / other_frac
  [:yes, :no, :other].each do |type|
    define_method("#{type}_frac") { ((self["#{type}_count".to_sym].to_f / total_count.to_f) * 100) }
  end
end
