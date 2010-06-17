class AddVotesmartPhotoUrlToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :votesmart_photo_url, :string
  end

  def self.down
    remove_column :people, :votesmart_photo_url
  end
end
