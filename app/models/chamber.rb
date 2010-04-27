class Chamber < ActiveRecord::Base
  belongs_to :legislature
  has_many :districts
  has_one :state, :through => :legislature

  validates_uniqueness_of :name, :scope => :legislature_id
  validates_uniqueness_of :type, :scope => :legislature_id
  validates_numericality_of :term_length, :only_integer => true

end
