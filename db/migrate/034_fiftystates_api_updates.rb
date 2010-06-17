class FiftystatesApiUpdates < ActiveRecord::Migration
  def self.up
    change_column :people, :fiftystates_id, :string
    add_column :committees, :fiftystates_id, :string
  end

  def self.down
    # change_column :people, :fiftystates_id, :integer
    remove_column :committees, :fiftystates_id
  end
end
