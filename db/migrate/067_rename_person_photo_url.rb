class RenamePersonPhotoUrl < ActiveRecord::Migration
  def self.up
    rename_column :people, :openstates_photo_url, :photo_url
  end

  def self.down
    rename_column :people, :photo_url, :openstates_photo_url
  end
end
