class CreateChambers < ActiveRecord::Migration
  def self.up
    create_table :chambers do |t|
      t.references :legislature
      t.string :type
      t.string :title
      t.string :name
      t.integer :term_length
    end
    
    execute "ALTER TABLE chambers
     ADD CONSTRAINT chamber_legislature_fk
     FOREIGN KEY (legislature_id) REFERENCES legislatures (id);"
    
    add_column :districts, :chamber_id, :integer
  end

  def self.down
    execute "ALTER TABLE chambers DROP CONSTRAINT chamber_legislature_fk;"
    
    drop_table :chambers
  end
end
