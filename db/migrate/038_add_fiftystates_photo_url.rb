class AddFiftystatesPhotoUrl < ActiveRecord::Migration
  def self.up
    add_column :people, :fiftystates_photo_url, :string
  end

  def self.down
    remove_column :people, :fiftystates_photo_url
  end
end
