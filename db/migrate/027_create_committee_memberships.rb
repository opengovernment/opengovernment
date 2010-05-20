class CreateCommitteeMemberships < ActiveRecord::Migration
  def self.up
    create_table :committee_memberships do |t|
      t.integer :person_id, :session_id, :committee_id
    end
  end

  def self.down
    drop_table :committee_memberships
  end
end
