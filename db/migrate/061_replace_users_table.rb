class ReplaceUsersTable < ActiveRecord::Migration
  def self.up
    drop_table :users
    create_table :users do |t|
        t.database_authenticatable
        t.confirmable
        t.recoverable
        t.rememberable
        t.trackable
        t.timestamps
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
