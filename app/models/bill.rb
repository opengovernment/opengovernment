class Bill < ActiveRecord::Base
  belongs_to :state
  belongs_to :session
  belongs_to :chamber

  has_many :sponsorships, :dependent => :destroy
  has_many :sponsors, :through  => :sponsorships

  has_many :versions, :dependent => :destroy
  has_many :actions, :dependent => :destroy
  has_many :votes, :dependent => :destroy

  has_many :upper_chamber_votes, :class_name => "Vote", :finder_sql => %q{
    SELECT * from votes where chamber_id = #{self.state.legislature.upper_chamber.id}
  }

  has_many :lower_chamber_votes, :class_name => "Vote", :finder_sql => %q{
    SELECT * from votes where chamber_id = #{self.state.legislature.lower_chamber.id}
  }

  class << self
    def find_by_param(param)
      find_by_bill_number(param.titleize.upcase)
    end
  end

  def to_param
    bill_number.parameterize
  end
end
