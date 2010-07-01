class IncreaseExcerptLimitOnCitations < ActiveRecord::Migration
  def self.up
    change_column :citations, :excerpt, :string, :limit => 4000
    change_column :citations, :title, :string, :limit => 1000
  end

  def self.down
    change_column :citations, :excerpt, :string, :limit => 1000
    change_column :citations, :title, :string    
  end
end
