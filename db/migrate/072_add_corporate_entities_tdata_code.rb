class AddCorporateEntitiesTdataCode < ActiveRecord::Migration
  def self.up
    # You need to run rake load:businesses load:contributions after this migration to get contributions back.
    remove_column :corporate_entities, :nimsp_code
    remove_column :corporate_entities, :id
    add_column :corporate_entities, :transparencydata_code, :string, :limit => 10, :primary_key => true
    add_index :corporate_entities, :transparencydata_code, :name => 'transparencydata_code_un', :unique => true
    add_column :corporate_entities, :transparencydata_order, :string, :limit => 10
    add_column :corporate_entities, :parent_name, :string
    change_column :contributions, :business_id, :string, :limit => 10
  end

  def self.down
    remove_column :corporate_entities, :transparencydata_code
    add_column :corporate_entities, :id, :integer, :primary_key => true
    remove_column :corporate_entities, :transparencydata_order
    remove_column :corporate_entities, :parent_name
    add_column :corporate_entities, :nimsp_code, :integer
    change_column :contributions, :business_id, :integer
  end

end
