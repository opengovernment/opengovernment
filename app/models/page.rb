class Page
  include MongoMapper::Document
  key :url, :required => true, :indexed => true
  key :og_object_id, :indexed => true
  key :og_object_type, :indexed => true
  many :views, :class => View
end
