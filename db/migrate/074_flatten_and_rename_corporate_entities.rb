class FlattenAndRenameCorporateEntities < ActiveRecord::Migration
  def self.up
    rename_table :corporate_entities, :industries
    remove_column :industries, :sector_id, :type, :industry_id
    rename_column :contributions, :business_id, :industry_id
  end

  def self.down
    rename_table :industries, :corporate_entities
    add_column :corporate_entities, :sector_id, :integer
    add_column :corporate_entities, :industry_id, :integer
    add_column :corporate_entities, :type, :string    
    rename_column :contributions, :industry_id, :business_id
  end
end
