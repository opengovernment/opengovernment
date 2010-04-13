class CreatePlaces < ActiveRecord::Migration
  def self.up
    # Detect PostGIS
    unless ActiveRecord::Base.connection.table_exists?("geometry_columns")
      raise "You need to install PostGIS in order to run this migration."
    end

    create_table :district_types do |t|
      t.string :name
      t.string :description
      t.boolean :at_large
    end

    create_table :districts do |t|
      t.string :name
      t.string :census_sld
      t.references :district_type
      t.references :state
      t.multi_polygon :geom, :srid => District::SRID
      t.string :vintage, :limit => 4 # From the census data. A year ('06') or congress ('110')
    end

    add_index :districts, :geom, :spatial => true

    create_table :states do |t|
      t.string :name, :null => false
      t.string :abbrev, :null => false
      t.boolean :unicameral, :default => false
      t.integer :fips_code
      t.datetime :launch_date
    end

  end

  def self.down
    drop_table :states
    remove_index :districts, :geom
    drop_table :districts
    drop_table :district_types
  end
end
