class AddCommitteeType < ActiveRecord::Migration
  def self.up
    add_column :committees, :type, :string, :null => false, :default => "Committee"
  end

  def self.down
    remove_column :committees, :type, :string
  end
end
