class Committee < ActiveRecord::Base
  belongs_to :legislature
  has_many :committee_memberships
  has_many :members, :through => :committee_memberships, :source => :person
  belongs_to :parent, :class_name => 'Committee'

  define_index do
    indexes name, :sortable => true
    has legislature(:state_id), :as => :state_id, :type => :integer
  end

  SORTABLE_BY = {
    "Name" => "name desc",
  }.freeze

  def to_param
    [id, name.parameterize].join('-')
  end

  def self.subclass_from_openstates_chamber(t)
    case t
    when "lower"
      ::LowerCommittee
    when "upper"
      ::UpperCommittee
    when "joint"
      ::JointCommittee
    end
  end

  def type_fm
    if self.class == ::LowerCommittee
      legislature.lower_chamber.short_name
    elsif self.class == ::UpperCommittee
      legislature.upper_chamber.short_name
    elsif self.class == ::JointCommittee
      'Joint'
    end
  end

end
