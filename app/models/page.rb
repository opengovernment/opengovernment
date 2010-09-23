class Page
  include MongoMapper::Document
  key :url, String, :required => true, :indexed => true
  key :og_object_id, Integer, :indexed => true
  key :og_object_type, String, :indexed => true
  many :views, :class => View
  scope :by_object, lambda {|object_type, object_id| where({:og_object_id => object_id, :og_object_type => object_type})}
  scope :most_viewed, lambda {|object_type| where(:og_object_type => object_type).limit(10)}
end
