class Sponsorship < ActiveRecord::Base
  belongs_to :bill
  belongs_to :sponsor, :class_name => 'Person'
  validates_presence_of :bill_id
  validates_presence_of :sponsor_id, :if => 'sponsor_name.blank?'
  validates_presence_of :sponsor_name, :if => 'sponsor_id.blank?'

  def kind_fm
    kind.humanize.downcase
  end

end
