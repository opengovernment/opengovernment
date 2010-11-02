class RemoveVotesmartPhotoUrl < ActiveRecord::Migration
  def self.up
    remove_column :people, :votesmart_photo_url
  end

  def self.down
    add_column :people, :votesmart_photo_url, :string
  end
end
