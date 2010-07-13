class CreateBillsSubjects < ActiveRecord::Migration
  def self.up
    create_table :bills_subjects do |t|
      t.integer :bill_id
      t.integer :subject_id
      t.timestamps
    end
  end

  def self.down
    drop_table :bills_subjects
  end
end
