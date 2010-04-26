class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.string :email
      t.references :state
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
