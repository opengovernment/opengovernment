class Person < ActiveRecord::Base
  validates_inclusion_of :gender, :in => ["M", "F"], :allow_blank => true
  validates_presence_of :first_name, :last_name

  has_many :roles, :dependent => :destroy
  has_one :current_role, :class_name => 'Role'
  has_one :chamber, :through => :current_role

  def full_name
    ([first_name, middle_name, last_name].join(' ') + (suffix? ? ", #{suffix}" : "")).squeeze(' ')
  end

  def official_name
    chamber ? [chamber.title, full_name].join(' ').squeeze(' ') : full_name
  end

end
