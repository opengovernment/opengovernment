class DemocraticDemocratPartyFix < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE roles DROP CONSTRAINT party_ck;"
    execute "UPDATE roles set party = 'Democrat' where party = 'Democratic'"
    execute "ALTER TABLE roles ADD CONSTRAINT party_ck CHECK (party in ('Democrat', 'Republican', 'Independent'));"
  end

  def self.down
    execute "ALTER TABLE roles DROP CONSTRAINT party_ck;"
    execute "UPDATE roles set party = 'Democratic' where party = 'Democrat'"
    execute "ALTER TABLE roles ADD CONSTRAINT party_ck CHECK (party in ('Democratic', 'Republican', 'Independent'));"
  end
end
