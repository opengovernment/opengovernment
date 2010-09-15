class Vote < ActiveRecord::Base
  belongs_to :bill
  belongs_to :chamber
  has_many :roll_calls, :dependent => :destroy

  default_scope :order => 'votes.date desc'

  def roll_calls_by_vote_type
    roll_calls = RollCall.where(:vote_id => id).order("case roll_calls.vote_type when 'yes' then 0 when 'no' then 1 when 'other' then 2 end, people.last_name").joins(:person).includes(:roles)
    roll_calls.group_by(&:vote_type)
  end

  def outcome_class
    passed ? 'vote-passed' : 'vote-failed'
  end
  
  def total_count
    yes_count + no_count + other_count
  end

  # These two methods provide a naive algorithm that assumes every motion requires a majority
  # of members present and voting to pass.
  #
  # "Majority of those present and voting" should be the default, but we need to look for
  # exceptions like urgency measures. This information may be best stored at the state or chamber level.
  #
  def needed_to_pass_frac
    0.5
  end
  
  def needed_to_pass_pct
    needed_to_pass_frac * 100
  end

  def needed_to_pass
    ((yes_count + no_count + other_count) * needed_to_pass_frac).round
  end
  
  # yes_frac / no_frac / other_frac
  [:yes, :no, :other].each do |type|
    define_method("#{type}_pct") { ((self["#{type}_count".to_sym].to_f / total_count.to_f) * 100) }
  end
end
