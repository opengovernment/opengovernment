class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :yes_count
      t.integer :no_count
      t.integer :other_count
      t.integer :bill_id
      t.datetime :date
      t.boolean :passed
      t.integer :chamber_id
      t.string :legislature_vote_id
      t.string :motion
      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
