class RemoveBillSources < ActiveRecord::Migration
  def self.up
    drop_table :bill_sources
    drop_table :industries
    drop_table :subscriptions
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
