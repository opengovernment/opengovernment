class AddBillMd5s < ActiveRecord::Migration
  def self.up
    add_column :bills, :openstates_md5sum, :string, :limit => 50
  end

  def self.down
    remove_column :bills, :openstates_md5sum
  end
end
