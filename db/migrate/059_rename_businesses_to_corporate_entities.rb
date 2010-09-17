class RenameBusinessesToCorporateEntities < ActiveRecord::Migration
  def self.up
    rename_table :businesses, :corporate_entities
    rename_column :contributions, :business_id, :corporate_entity_id
    rename_column :contributions, :candidate_id, :person_id
  end

  def self.down
    rename_table :corporate_entities, :businesses
    rename_column :contributions, :corporate_entity_id, :business_id
    rename_column :contributions, :person_id, :candidate_id
  end
end
