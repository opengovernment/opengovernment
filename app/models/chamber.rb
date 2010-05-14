class Chamber < ActiveRecord::Base
  belongs_to :legislature
  has_many :districts
  has_many :current_legislators, :through => :districts
  has_one :state, :through => :legislature
  has_many :bills

  validates_uniqueness_of :name, :scope => :legislature_id
  validates_uniqueness_of :type, :scope => :legislature_id
  validates_numericality_of :term_length, :only_integer => true
end
