class CreateBusinesses < ActiveRecord::Migration
  def self.up
    create_table :businesses do |t|
      t.string :business_name
      t.string :industry_name
      t.string :sector_name
      t.integer :nimsp_industry_code
      t.integer :nimsp_sector_code
      t.timestamps
    end
  end

  def self.down
    drop_table :businesses
  end
end
