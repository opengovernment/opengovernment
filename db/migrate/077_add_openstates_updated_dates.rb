class AddOpenstatesUpdatedDates < ActiveRecord::Migration
  def self.up
    add_column :people, :openstates_updated_at, :datetime
    add_column :bills, :openstates_updated_at, :datetime
    execute "update bills set openstates_updated_at = updated_at"
    execute "update people set openstates_updated_at = updated_at"
  end

  def self.down
    remove_column :bills, :openstates_updated_at
    remove_column :people, :openstates_updated_at
  end
end
