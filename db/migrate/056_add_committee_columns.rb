class AddCommitteeColumns < ActiveRecord::Migration
  def self.up
    add_column :committee_memberships, :full_name, :string
    add_column :committee_memberships, :role, :string
    add_column :committees, :parent_id, :integer
  end

  def self.down
    remove_column :committee_memberships, :full_name
    remove_column :committee_memberships, :role
    remove_column :committees, :parent_id
  end
end
