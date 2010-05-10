class Person < ActiveRecord::Base
  validates_inclusion_of :gender, :in => ["M", "F"], :allow_blank => true
  validates_presence_of :first_name, :last_name

  has_many :roles, :dependent => :destroy
  has_many :addresses, :dependent => :destroy

  has_one :current_role, :class_name => 'Role'
  has_one :chamber, :through => :current_role

  named_scope :with_votesmart_id, :conditions => ["votesmart_id is not null"]
  named_scope :with_current_role, :include => :roles, :conditions => Role::CURRENT

  has_many :sponsorships, :foreign_key => "sponsor_id"
  has_many :sponsored_bills, :class_name => 'Bill', :through => :sponsorships, :source => :bill

  has_many :roll_calls, :foreign_key => "leg_id"
  has_many :votes, :through => :roll_calls

  has_many :voted_bills, :class_name => 'Bill', :finder_sql => %q{
    SELECT distinct bills.* from bills
    inner join votes on votes.bill_id = bills.id
    inner join roll_calls on roll_calls.vote_id = votes.id
    where roll_calls.leg_id = #{self.id}
  }

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
