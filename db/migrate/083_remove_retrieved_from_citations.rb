class RemoveRetrievedFromCitations < ActiveRecord::Migration
  def self.up
    remove_column :citations, :retrieved
  end

  def self.down
    add_column :citations, :retrieved, :datetime
  end
end
