class Person < ActiveRecord::Base
  validates_inclusion_of :gender, :in => ["M", "F"], :allow_blank => true
  validates_presence_of :first_name, :last_name

  has_many :roles, :dependent => :destroy

  def full_name
    [first_name, middle_name, last_name].compact.join(' ') + suffix? ? ", #{suffix}" : nil
  end

end
