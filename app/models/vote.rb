class Vote < ActiveRecord::Base
  belongs_to :bill
  belongs_to :chamber
  has_many :roll_calls, :dependent => :destroy

  def roll_calls_by_vote_type
    RollCall.find_all_by_vote_id(id, :order => "case vote_type when 'yes' then 0 when 'no' then 1 when 'other' then 2 end", :include => [:person, :roles])
    # roll_calls.group_by(&:vote_type)
  end
end
