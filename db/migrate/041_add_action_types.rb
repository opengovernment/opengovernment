class AddActionTypes < ActiveRecord::Migration
  def self.up
    remove_column :actions, :actor_type
    add_column :actions, :action_number, :string
    add_column :actions, :kind, :string
  end

  def self.down
    add_column :actions, :actor_type, :string
    remove_column :actions, :action_number
    remove_column :actions, :kind
  end
end
