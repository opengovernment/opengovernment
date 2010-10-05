class ChangeRatingsRating < ActiveRecord::Migration
  def self.up
    change_column :ratings, :rating, :string
  end

  def self.down
    change_column :ratings, :rating, :integer
  end
end
