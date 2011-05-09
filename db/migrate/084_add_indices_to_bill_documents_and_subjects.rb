class AddIndicesToBillDocumentsAndSubjects < ActiveRecord::Migration
  def self.up
    add_index :bill_documents, [:document_type, :bill_id]
    add_index :bills_subjects, [:bill_id, :subject_id]
    add_index :bill_sponsorships, :bill_id
    add_index :citations, [:citeable_id, :citeable_type]
  end

  def self.down
    remove_index :bill_documents, :column => [:document_type, :bill_id]
    remove_index :bills_subjects, :column => [:bill_id, :subject_id]
    remove_index :bill_sponsorships, :column => :bill_id
    remove_index :citations, :column => [:citeable_id, :citeable_type]
  end
end
