class Page
  include MongoMapper::Document
  key :url, :required => true, :indexed => true
  key :og_object_id, :indexed => true
  key :og_object_type, :indexed => true
  many :views, :class => View
  scope :by_object, lambda {|object_id, object_type| where({:og_object_id => object_id, :og_object_type => object_type})}
end
