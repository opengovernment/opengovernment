class AddCorporateEntitiesTdataCode < ActiveRecord::Migration
  def self.up
    remove_column :corporate_entities, :nimsp_code
    add_column :corporate_entities, :transparencydata_code, :string, :limit => 5
  end

  def self.down
    remove_column :corporate_entities, :transparencydata_code
    add_column :corporate_entities, :nimsp_code, :integer
  end

end
