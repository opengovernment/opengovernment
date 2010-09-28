class PageView
  include MongoMapper::Document
  key :hour, Date
  key :total, Integer
#  key :uniques, Integer
end
