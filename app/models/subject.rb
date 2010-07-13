class Subject < ActiveRecord::Base
  has_many :bills_subjects
  has_many :bills, :through => :bills_subjects
end
