class CreateSponsorships < ActiveRecord::Migration
  def self.up
    create_table :sponsorships do |t|
      t.integer :bill_id
      t.integer :sponsor_id
      t.string :type
      t.timestamps
    end
  end

  def self.down
    drop_table :sponsorships
  end
end
