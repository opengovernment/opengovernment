class CreatePeople < ActiveRecord::Migration
  def self.up

    create_table :people do |t|
      t.string :first_name, :null => false
      t.string :middle_name
      t.string :last_name, :null => false
      t.integer :fiftystates_id
      t.integer :nimsp_candidate_id
      t.integer :votesmart_id
      t.integer :govtrack_id
      t.string :metavid_id
      t.string :bioguide_id
      t.string :opensecrets_id
      t.string :youtube_id
      t.string :suffix
      t.string :religion
      t.date :birthday
      t.string :gender # "M" "F" or nil
      t.timestamps
    end

  end

  def self.down
    drop_table :people
  end
end
