class AddLegislatureIdToCommittees < ActiveRecord::Migration
  def self.up
    add_column :committees, :legislature_id, :integer, :null => false
  end

  def self.down
    drop_column :committees, :legislature_id
  end
end
