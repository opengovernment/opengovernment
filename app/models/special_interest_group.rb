class SpecialInterestGroup < ActiveRecord::Base
  belongs_to :state
  belongs_to :category
  has_many :ratings, :foreign_key => 'sig_id', :order => "timespan desc"

  class << self
    def find_all_by_issue(issue)
      find_by_sql(["select * from v_tagged_sigs
              where tag_name = ?", issue.name])
    end
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
