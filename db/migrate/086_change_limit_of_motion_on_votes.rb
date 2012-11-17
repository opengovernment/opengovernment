class ChangeLimitOfMotionOnVotes < ActiveRecord::Migration
  def self.up
    change_column :votes, :motion, :string, :limit => 1000
  end

  def self.down
    change_column :votes, :motion, :string
  end
end
