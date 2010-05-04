class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.integer :bill_id
      t.string :url
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :versions
  end
end
