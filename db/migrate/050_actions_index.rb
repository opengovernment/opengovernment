class ActionsIndex < ActiveRecord::Migration
  def self.up
    add_index :actions, [:bill_id, :date]
  end

  def self.down
  end
end
