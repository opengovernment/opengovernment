class Category < ActiveRecord::Base
  has_many :special_interest_groups

  scope :aggregates_for_person, lambda { |person_id| joins(:special_interest_groups => :ratings).select("categories.id, categories.name, count(ratings.id) as entries").group("categories.name, categories.id").where(["ratings.person_id = ?", person_id]) }
    
#    (["select c.id, c.name, count(r.id) as entries from categories c, special_interest_groups sigs, ratings r where c.id = sigs.category_id and r.sig_id = sigs.id and r.person_id = ? group by c.name, c.id", person_id]) }

  acts_as_taggable
  acts_as_taggable_on :issues
end
