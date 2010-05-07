class ChangeTitleSizeOnBills < ActiveRecord::Migration
  def self.up
    change_column :bills, :title, :string, :limit => 1000
  end

  def self.down
    change_column :bills, :title, :string
  end
end
