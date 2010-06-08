class CreateLegislatures < ActiveRecord::Migration
  def self.up
    create_table :legislatures do |t|
      t.string :name # maps to fiftystate#legislature_name
      t.references :state
    end

    execute "ALTER TABLE legislatures
      ADD CONSTRAINT legislatures_state_fk
      FOREIGN KEY (state_id) REFERENCES states (id);"
  end

  def self.down
    execute "ALTER TABLE legislatures DROP CONSTRAINT legislatures_state_fk;"

    drop_table :legislatures
  end
end
