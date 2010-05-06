class CreateRolls < ActiveRecord::Migration
  def self.up
    create_table :rolls do |t|
      t.integer :vote_id
      t.integer :leg_id
      t.string :vote_type
      t.timestamps
    end
  end

  def self.down
    drop_table :rolls
  end
end
