class CreatePlaces < ActiveRecord::Migration
  def self.up
    # Detect PostGIS
    unless ActiveRecord::Base.connection.table_exists?("geometry_columns")
      raise "You need to install PostGIS in order to run this migration."
    end
    
    create_table :states do |t|
      t.string :name, :null => false
      t.string :abbrev, :null => false, :limit => 2
      t.boolean :unicameral, :default => false
      t.integer :fips_code
      t.datetime :launch_date
    end

    create_table :districts do |t|
      t.string :name, :null => false
      t.string :census_sld
      t.string :census_district_type
      t.boolean :at_large
      t.references :state, :null => false
      t.multi_polygon :geom, :srid => District::SRID
      t.string :vintage, :limit => 4 # From the census data. A year ('06') or congress ('110')
    end

    add_index :districts, :geom, :spatial => true

    execute "ALTER TABLE districts
    ADD CONSTRAINT districts_state_fk
    FOREIGN KEY (state_id) REFERENCES states (id);"

  end

  def self.down
    execute "ALTER TABLE districts DROP CONSTRAINT districts_state_fk;"
    remove_index :districts, :geom
    drop_table :districts
    drop_table :states
  end
end
