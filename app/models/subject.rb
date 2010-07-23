class Subject < ActiveRecord::Base
  has_many :bills_subjects
  has_many :bills, :through => :bills_subjects

  acts_as_taggable
  acts_as_taggable_on :issues
end
