class BillsSubject < ActiveRecord::Base
  belongs_to :bill
  belongs_to :subject
end
