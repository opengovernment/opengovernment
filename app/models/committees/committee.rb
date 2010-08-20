class Committee < ActiveRecord::Base
  has_one :parent, :class_name => "Committee", :foreign_key => "votesmart_id", :primary_key => "votesmart_parent_id"
  belongs_to :legislature
  has_many :committee_memberships
  has_many :members, :through => :committee_memberships, :source => :person

  define_index do
    indexes name, :sortable => true
  end

  SORTABLE_BY = {
    "Name" => "name desc",
  }.freeze

  def to_param
    [id, name.parameterize].join('-')
  end

  def self.subclass_from_votesmart_type(t)
    case t
    when "S"
      ::UpperCommittee
    when "H"
      ::LowerCommittee
    when "J"
      ::JointCommittee
    end
  end

  def type_fm
    case votesmart_type_id
    when 'S'
      legislature.upper_chamber.short_name
    when 'H'
      legislature.lower_chamber.short_name
    when 'J'
      'Joint'
    end
  end

end
