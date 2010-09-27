class AddVoteThresholdCommittee < ActiveRecord::Migration
  def self.up
    add_column :votes, :committee_name, :string
    add_column :votes, :threshold, :float
  end

  def self.down
    remove_column :votes, :threshold
    remove_column :votes, :committee_name
  end
end
