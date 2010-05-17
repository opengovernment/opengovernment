class RenameVotesFiftystatesId < ActiveRecord::Migration
  def self.up
    rename_column :votes, :legislature_vote_id, :fiftystates_id
  end

  def self.down
    rename_column :votes, :fiftystates_id, :legislature_vote_id
  end
end
