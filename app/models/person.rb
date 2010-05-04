class Person < ActiveRecord::Base
  validates_inclusion_of :gender, :in => ["M", "F"], :allow_blank => true
  validates_presence_of :first_name, :last_name

  has_many :roles, :dependent => :destroy
  has_many :addresses, :dependent => :destroy

  has_one :current_role, :class_name => 'Role'
  has_one :chamber, :through => :current_role

  named_scope :with_votesmart_id, :conditions => ["votesmart_id is not null"]
  named_scope :with_current_role, :include => :roles, :conditions => Role::CURRENT

  has_many :actions, :as => :actor
  

  def full_name
    ([first_name, middle_name, last_name].join(' ') + (suffix? ? ", #{suffix}" : "")).squeeze(' ')
  end

  def official_name
    chamber ? [chamber.title, full_name].join(' ').squeeze(' ') : full_name
  end

  def youtube_url
    youtube_id.blank? ? nil : "http://www.youtube.com/user/" + youtube_id
  end

  def to_param
   "#{id}-#{full_name.parameterize}"
  end
end
