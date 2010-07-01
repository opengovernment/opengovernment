class RemoveColumnsFromBills < ActiveRecord::Migration
  def self.up
    remove_column :bills, :first_action_at
    remove_column :bills, :last_action_at
  end

  def self.down
    add_column :bills, :first_action_at, :datetime
    add_column :bills, :last_action_at, :datetime        
  end
end
