class RenameBillNumber < ActiveRecord::Migration
  def self.up
    rename_column :bills, :legislature_bill_id, :bill_number
  end

  def self.down
    rename_column :bills, :bill_number, :legislature_bill_id
  end
end
