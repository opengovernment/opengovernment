class IncreaseUrlOnCitations < ActiveRecord::Migration
  def self.up
    change_column :citations, :url, :string, :limit => 2000
  end

  def self.down
    change_column :citations, :url, :string    
  end
end