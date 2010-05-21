class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations do |t|
      t.string :url
      t.string :excerpt, :limit => 1000
      t.string :title
      t.string :source
      t.datetime :date
      t.float :weight
      t.integer :owner_id
      t.string :owner_type
      t.string :search_source
      t.timestamps
    end
  end

  def self.down
    drop_table :citations
  end
end
