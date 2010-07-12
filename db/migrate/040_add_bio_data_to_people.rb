class AddBioDataToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :bio_data, :string, :limit => 8000
  end

  def self.down
    remove_column :people, :bio_data
  end
end
