class Sponsorship < ActiveRecord::Base
  belongs_to :bill
  belongs_to :sponsor, :class_name => 'Person'

  def kind_fm
    kind.humanize.downcase
  end
end
