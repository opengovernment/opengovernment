class CreatePlaces < ActiveRecord::Migration
  def self.up
    # Detect PostGIS
    unless ActiveRecord::Base.connection.table_exists?("geometry_columns")
      raise "You need to install PostGIS in order to run this migration."
    end

    create_table :district_types do |t|
      t.string :name
      t.string :description
    end

    create_table :districts do |t|
      t.string :name
      t.boolean :at_large
      t.string :census_sld
      t.references :district_type
      t.references :state
      t.multi_polygon :geom, :srid => 4269 # Census SRID
    end

    add_index :districts, :geom, :spatial => true

    create_table :states do |t|
      t.string :name, :null => false
      t.string :abbrev, :null => false
      t.boolean :unicameral, :default => false
      t.integer :fips_code
      t.datetime :launch_date
    end
    
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
    
    create_table :legislatures_places do |t|
      t.integer :legislature_id
      t.integer :placeable_id
      t.string :placeable_type
    end
    
    create_table :people do |t|
      # ID column should hold fiftystates#leg_id
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :party
      t.references :legislature
    end
  end

  def self.down
    drop_table :people
    drop_table :legislatures_places
    drop_table :legislatures
    drop_table :states
    remove_index :districts, :geom
    drop_table :districts
    drop_table :district_types
  end
end
