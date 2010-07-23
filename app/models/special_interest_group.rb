class SpecialInterestGroup < ActiveRecord::Base
  belongs_to :state
  belongs_to :category
  has_many :ratings, :foreign_key => 'sig_id', :order => "timespan desc"

  def to_param
    "#{id}-#{name.parameterize}"
  end
end
