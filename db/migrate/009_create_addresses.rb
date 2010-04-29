class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.references :person, :null => false
      t.string :line_one
      t.string :line_two
      t.string :city
      t.references :state
      t.string :postal_code
      t.string :votesmart_type
      t.string :phone_one
      t.string :phone_two
      t.string :fax_one
      t.string :fax_two
      t.timestamps
    end

    execute "ALTER TABLE addresses
      ADD CONSTRAINT address_person_fk
      FOREIGN KEY (person_id) REFERENCES people (id);"

  end

  def self.down
    execute "ALTER TABLE addresses DROP CONSTRAINT address_person_fk;"
    
    drop_table :addresses
  end
end
