class AddStateBoundaries < ActiveRecord::Migration
  def self.up
    execute "CREATE SEQUENCE state_boundaries_id_seq
        START WITH 1
        INCREMENT BY 1
        NO MAXVALUE
        NO MINVALUE
        CACHE 1;"

    execute "CREATE TABLE state_boundaries (
        id integer primary key NOT NULL DEFAULT nextval('state_boundaries_id_seq'::regclass),
        state_id integer NOT NULL,
        fips_code character varying(2),
        vintage character varying(4),
        lsad character varying(2),
        region character varying(1),
        division character varying(1),
        geom geometry,
        CONSTRAINT enforce_dims_geom CHECK ((st_ndims(geom) = 2)),
        CONSTRAINT enforce_geotype_geom CHECK (((geometrytype(geom) = 'MULTIPOLYGON'::text) OR (geom IS NULL))),
        CONSTRAINT enforce_srid_geom CHECK ((st_srid(geom) = 4269))
    );"

    execute "CREATE INDEX index_state_boundaries_on_geom ON state_boundaries USING gist (geom);"
  end

  def self.down
  end
end
