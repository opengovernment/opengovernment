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
  end

  def self.down
    drop_table :addresses
  end
end
