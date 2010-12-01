class SpecialInterestGroup < ActiveRecord::Base
  belongs_to :state
  belongs_to :category
  has_many :ratings, :foreign_key => 'sig_id', :order => "timespan desc"

  def self.by_state_and_issue(state_id, issue, limit = 10)
    find_by_sql(["select * from v_tagged_sigs
            where tag_name = ? and state_id = ? limit ?", issue.name, state_id, limit])
  end

  def average_rating_for_chamber_and_year(chamber_id, year)
    ratings = Rating.find_by_sql(["select avg(rating) as average_rating, count(*) as rating_count from v_ratings a join roles r on (r.person_id = a.person_id) where timespan = ? and chamber_id = ? and a.sig_id = ?", year, chamber_id, id])
    [ratings.first.try(:average_rating), ratings.first.try(:rating_count)]
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
