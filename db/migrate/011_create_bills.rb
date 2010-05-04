class CreateBills < ActiveRecord::Migration
  def self.up
    create_table :bills do |t|
      t.string :title
      t.integer :state_id
      t.integer :session_id
      t.string :fiftystates_id
      t.string :legislature_bill_id
      t.integer :chamber_id
      t.timestamps
    end
  end

  def self.down
    drop_table :bills
  end
end
