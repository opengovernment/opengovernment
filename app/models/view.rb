class View
  include MongoMapper::Document
  key :created_at
  key :user_id
  belongs_to :page

  def before_save
    created_at = Time.now
  end
end
