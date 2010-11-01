class ChangeCitations < ActiveRecord::Migration
  def self.up
    rename_table :citations, :mentions
    create_table :citations do |t|
      t.integer :citeable_id
      t.string :citeable_type
      t.datetime :retrieved
      t.string :url
    end
  end

  def self.down
    drop_table :citations
    rename_table :mentions, :citations
  end
end
