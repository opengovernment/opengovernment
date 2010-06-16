class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.references :person
      t.integer :rating
      t.integer :timespan
      t.integer :sig_id
      t.integer :votesmart_id
      t.string :rating_text, :limit => 4000
      t.timestamps
    end

    execute "ALTER TABLE ratings
     ADD CONSTRAINT ratings_sig_id_fk
     FOREIGN KEY (sig_id) REFERENCES special_interest_groups (id);"
  end

  def self.down
    drop_table :ratings
  end
end
