class AddWikipediaUrlToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :bio_url, :string
  end

  def self.down
    remove_column :people, :bio_url
  end
end
