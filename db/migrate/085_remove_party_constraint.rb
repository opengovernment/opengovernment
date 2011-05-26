class RemovePartyConstraint < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE roles drop CONSTRAINT party_ck"
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end
