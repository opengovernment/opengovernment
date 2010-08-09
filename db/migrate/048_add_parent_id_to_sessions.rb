class AddParentIdToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :parent_id, :integer
  end

  def self.down
    remove_column :sessions, :parent_id
  end
end
