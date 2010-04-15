class CreateLegislatures < ActiveRecord::Migration
  def self.up
    create_table :legislatures do |t|
      t.string :name # maps to fiftystate#legislature_name
      t.string :upper_chamber_name
      t.string :lower_chamber_name
      t.integer :upper_chamber_term
      t.integer :lower_chamber_term
      t.string :upper_chamber_title
      t.string :lower_chamber_title
      t.timestamps
    end

    create_table :sessions do |t|
      t.references :legislature
      t.integer :start_year
      t.integer :end_year
      t.string :name
    end

    create_table :people do |t|
      # ID column should hold fiftystates#leg_id
      t.integer :nimsp_candidate_id
      t.integer :votesmart_id
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :party
    end

    create_table :roles do |t|
      t.references :person
      t.references :district # null OK
      t.references :session
      t.references :committe
      t.references :party
      t.string :type # "member", "committee member"
    end
  end

  def self.down
    drop_table :roles
    drop_table :people
    drop_table :sessions
    drop_table :legislatures
  end
end
