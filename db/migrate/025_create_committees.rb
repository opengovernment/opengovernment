class CreateCommittees < ActiveRecord::Migration
  def self.up
    create_table :committees do |t|
      t.string :name, :null => false
      t.integer :votesmart_parent_id # references committees
      t.integer :votesmart_id
      t.string :votesmart_type_id, :limit => 1
      t.string :url
      t.timestamps
    end
  end

  def self.down
    drop_table :committees
  end
end
