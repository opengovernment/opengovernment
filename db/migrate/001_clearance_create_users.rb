class ClearanceCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable
      t.confirmable
      t.rememberable
      t.recoverable
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
