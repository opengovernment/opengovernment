class AddDocumentsToBills < ActiveRecord::Migration
  def self.up
    add_column :bill_versions, :document_file_name,    :string
    add_column :bill_versions, :document_content_type, :string
    add_column :bill_versions, :document_file_size,    :integer
    add_column :bill_versions, :document_updated_at,   :datetime
    
    add_column :bill_documents, :document_file_name,    :string
    add_column :bill_documents, :document_content_type, :string
    add_column :bill_documents, :document_file_size,    :integer
    add_column :bill_documents, :document_updated_at,   :datetime
  end

  def self.down
    remove_column :bill_versions, :document_file_name
    remove_column :bill_versions, :document_content_type
    remove_column :bill_versions, :document_file_size
    remove_column :bill_versions, :document_updated_at
    
    remove_column :bill_documents, :document_file_name
    remove_column :bill_documents, :document_content_type
    remove_column :bill_documents, :document_file_size
    remove_column :bill_documents, :document_updated_at
  end
end
