class AddCorporateEntitiesTdataCode < ActiveRecord::Migration
  def self.up
    remove_column :corporate_entities, :nimsp_code
    remove_column :corporate_entities, :id
    add_column :corporate_entities, :transparencydata_code, :string, :limit => 5
    add_column :corporate_entities, :transparencydata_order, :string, :limit => 3
    add_column :corporate_entities, :parent_name, :string
  end

  def self.down
    remove_column :corporate_entities, :transparencydata_code
    remove_column :corporate_entities, :transparencydata_order
    remove_column :corporate_entities, :parent_name
    add_column :corporate_entities, :nimsp_code, :integer
  end

end
