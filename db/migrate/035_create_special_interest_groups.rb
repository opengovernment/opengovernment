class CreateSpecialInterestGroups < ActiveRecord::Migration
  def self.up
    create_table :special_interest_groups do |t|
      t.references :state
      t.references :issue
      t.string :name
      t.string :description, :limit => 4000
      t.string :contact_name
      t.string :city
      t.string :address
      t.string :zip
      t.string :url
      t.string :phone_one
      t.integer :votesmart_id
      t.string :phone_two
      t.string :email
      t.string :fax
      t.timestamps
    end
  end

  def self.down
    drop_table :special_interest_groups
  end
end
