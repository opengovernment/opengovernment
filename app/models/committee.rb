class Committee < ActiveRecord::Base
  has_one :parent, :class_name => "Committee", :foreign_key => "votesmart_id", :primary_key => "votesmart_parent_id"
end
