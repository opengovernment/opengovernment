class RenameBusinessesToCorporateEntities < ActiveRecord::Migration
  def self.up
    remove_column :businesses, :ancestry
    rename_table :businesses, :corporate_entities
    rename_column :contributions, :candidate_id, :person_id
    change_table(:corporate_entities) do |t|
      t.integer :sector_id
      t.integer :industry_id
    end
  end

  def self.down
    add_column :businesses, :ancestry, :string
    rename_table :corporate_entities, :businesses
    rename_column :contributions, :person_id, :candidate_id
    change_table(:corporate_entites) do |t|
      t.remove :sector_id
      t.remove :industry_id
    end
  end
end
