class CreateContributions < ActiveRecord::Migration
  def self.up
    create_table :contributions do |t|
      t.integer :candidate_id
      t.string :business_name
      t.string :contributor_state
      t.string :industry_name
      t.string :contributor_occupation
      t.string :contributor_employer
      t.string :amount
      t.date :date
      t.string :sector_name
      t.integer :nimsp_industry_code
      t.integer :nimsp_sector_code
      t.string :contributor_city
      t.string :contributor_name
      t.string :contributor_zipcode
      t.timestamps
    end
  end

  def self.down
    drop_table :contributions
  end
end
