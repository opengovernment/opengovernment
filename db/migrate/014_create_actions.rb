class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.integer :bill_id
      t.datetime :date
      t.integer :actor_id
      t.string :actor_type
      t.string :action
      t.timestamps
    end
  end

  def self.down
    drop_table :actions
  end
end
