class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.references :legislature
      t.integer :start_year
      t.integer :end_year
      t.string :name
      t.timestamps
    end

    execute "ALTER TABLE sessions
     ADD CONSTRAINT session_legislature_fk
     FOREIGN KEY (legislature_id) REFERENCES legislatures (id);"

  end

  def self.down
    execute "ALTER TABLE sessions DROP CONSTRAINT session_legislature_fk;"
    
    drop_table :sessions
  end
end
