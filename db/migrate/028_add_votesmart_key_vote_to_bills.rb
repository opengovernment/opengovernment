class AddVotesmartKeyVoteToBills < ActiveRecord::Migration
  def self.up
    add_column :bills, :votesmart_key_vote, :boolean, :default => false, :null => false
    add_column :bills, :votesmart_id, :integer
  end

  def self.down
    remove_column :bills, :votesmart_key_vote
    remove_column :bills, :votesmart_id
  end
end
