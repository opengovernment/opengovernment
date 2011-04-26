class AddKeyVotesTable < ActiveRecord::Migration
  def self.up
    create_table :key_votes do |t|
      t.integer :bill_id, :null => false
      t.integer :votesmart_action_id, :null => false
      t.string :title
      t.text :highlight
      t.text :synopsis
      t.string :stage
      t.string :level
      t.string :url
    end
  end

  def self.down
    drop_table :key_votes
  end
end
