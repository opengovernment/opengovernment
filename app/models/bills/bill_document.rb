class BillDocument < ActiveRecord::Base
  belongs_to :bill
  include ScrapedDocument
  include SplitDocument

  def to_param
    [id, name.parameterize].join('-')
  end
end
