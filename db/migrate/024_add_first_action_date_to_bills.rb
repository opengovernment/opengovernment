class AddFirstActionDateToBills < ActiveRecord::Migration
  def self.up
    add_column :bills, :first_action_at, :datetime
    add_column :bills, :last_action_at, :datetime

    execute "update bills b set first_action_at = (select min(date) from actions a where a.bill_id = b.id), last_action_at = (select max(date) from actions a where a.bill_id = b.id)"
  end

  def self.down
    remove_column :bills, :first_action_at
    remove_column :bills, :last_action_at
  end
end