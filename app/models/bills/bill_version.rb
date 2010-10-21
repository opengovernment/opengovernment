class BillVersion < ActiveRecord::Base
  belongs_to :bill
  has_attached_file :document
end
