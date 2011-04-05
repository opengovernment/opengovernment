class AddTotalPagesToAttachments < ActiveRecord::Migration
  def self.up
    add_column :bill_versions, :total_pages, :integer
    add_column :bill_versions, :description, :text
    add_column :bill_versions, :published_at, :datetime
    add_column :bill_versions, :components_available, :boolean, :null => false, :default => false
    add_column :bill_versions, :document_type, :string
    add_column :bill_versions, :document_sync_queued, :boolean, :null => false, :default => false
    add_column :bill_versions, :component_sync_queued, :boolean, :null => false, :default => false
    
    execute "update bill_versions set document_type = 'version'"

    execute "insert into bill_versions (bill_id, url, name, created_at, updated_at, document_type) select bill_id, url, name, current_timestamp, current_timestamp, 'document' from bill_documents"

    drop_table :bill_documents

    rename_table :bill_versions, :bill_documents

  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
   end
end
