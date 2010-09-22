class View
  include MongoMapper::EmbeddedDocument

  key :created_at
  key :og_user_id, Integer

#  scope :since, lambda {|date| where(:created_at.gte => date)}
end
