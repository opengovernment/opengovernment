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
end
