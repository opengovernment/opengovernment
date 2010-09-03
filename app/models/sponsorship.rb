class Sponsorship < ActiveRecord::Base
  belongs_to :bill
  belongs_to :sponsor, :class_name => 'Person'
  validates_presence_of :bill_id
  validates_presence_of :sponsor_id, :if => 'sponsor_name.blank?'
  validates_presence_of :sponsor_name, :if => 'sponsor_id.blank?'
  validate :sponsor_multual_exclusivity
  
  def kind_fm
    kind.humanize.downcase
  end
  
  private

  def sponsor_multual_exclusivity
    errors.add(:base, "Must supply a sponsor_id or a sponsor_name, not both.") if (sponsor_id? && sponsor_name?)
  end
end
