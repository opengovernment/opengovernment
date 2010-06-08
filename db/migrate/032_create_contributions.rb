class CreateContributions < ActiveRecord::Migration
  def self.up
    create_table :contributions do |t|
      t.integer :candidate_id
      t.integer :business_id
      t.integer :contributor_state_id
      t.string :contributor_occupation
      t.string :contributor_employer
      t.integer :amount
      t.date :date
      t.string :contributor_city
      t.string :contributor_name
      t.string :contributor_zipcode
      t.timestamps
    end

    execute "ALTER TABLE contributions
     ADD CONSTRAINT contributions_business_id_fk
     FOREIGN KEY (business_id) REFERENCES businesses (id);"          
  end

  def self.down
    drop_table :contributions
  end
end
