class AddRatingNameToRatings < ActiveRecord::Migration
  def self.up
    add_column :ratings, :rating_name, :string
  end

  def self.down
    remove_column :ratings, :rating_name
  end
end
