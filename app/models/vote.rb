class Vote < ActiveRecord::Base
  belongs_to :bill
  belongs_to :chamber
  has_many :roll_calls

  def roll_calls_by_vote_type
    roll_calls = RollCall.find_all_by_vote_id(id, :order => "case vote_type when 'yes' then 0 when 'no' then 1 when 'other' then 2 end", :include => [:person])
    roll_calls.group_by(&:vote_type)
  end
end

