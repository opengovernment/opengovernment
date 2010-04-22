class Session < ActiveRecord::Base
  belongs_to :legislature
  has_many :roles
  named_scope :active, :conditions => ["date_part('year', current_timestamp) between start_year and end_year"]

end
