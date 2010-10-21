class BillVersion < ActiveRecord::Base
  belongs_to :bill
  include ScrapedDocument
end
