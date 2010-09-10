class StandardizeRoleParties < ActiveRecord::Migration
  def self.up
    execute "update roles set party = 'Democratic' where party = 'Democrat'"
    execute "update roles set party = 'Independent' where party not in ('Democratic', 'Republican')"
    execute "ALTER TABLE roles ADD CONSTRAINT party_ck CHECK (party in ('Democratic', 'Republican', 'Independent'))"
  end

  def self.down
  end
end
