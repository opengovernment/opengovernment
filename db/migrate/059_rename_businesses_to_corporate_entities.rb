class RenameBusinessesToCorporateEntities < ActiveRecord::Migration
  def self.up
    remove_column :businesses, :ancestry
    rename_table :businesses, :corporate_entities
    rename_column :contributions, :candidate_id, :person_id
    add_column :contributions, :state_id, :integer
    change_table(:corporate_entities) do |t|
      t.integer :sector_id
      t.integer :industry_id
    end
  end

  def self.down
    change_table(:corporate_entites) do |t|
      t.remove :sector_id
      t.remove :industry_id
    end
    rename_table :corporate_entities, :businesses
    add_column :businesses, :ancestry, :string
    remove_column :contributions, :state_id
    rename_column :contributions, :person_id, :candidate_id
  end
end
