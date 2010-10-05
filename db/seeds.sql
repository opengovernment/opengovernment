-- Any executes from migrations must go in here, or they
-- will not be run when someone installs the app.

-- We create this table here because we're not using spatial_adapter anymore
-- (due to bugs & performance issues).
CREATE SEQUENCE districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE districts (
    id integer primary key NOT NULL DEFAULT nextval('districts_id_seq'::regclass),
    name character varying(255) NOT NULL,
    census_sld character varying(255),
    census_district_type character varying(255),
    at_large boolean,
    state_id integer NOT NULL,
    vintage character varying(4),
    chamber_id integer,
    geom geometry,
    CONSTRAINT enforce_dims_geom CHECK ((st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((geometrytype(geom) = 'MULTIPOLYGON'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((st_srid(geom) = 4269))
);

CREATE INDEX index_districts_on_geom ON districts USING gist (geom);

-- FUNCTIONS --
CREATE OR REPLACE FUNCTION beginning_of(year integer) RETURNS date AS $$
BEGIN
  RETURN to_date('1 Jan ' || year, 'DD Mon YYYY');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION end_of(year integer) RETURNS date AS $$
BEGIN
  RETURN to_date('31 Dec ' || year, 'DD Mon YYYY');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION upper_and_stripped(item varchar) RETURNS varchar as $$
begin
  RETURN upper(regexp_replace(item, E'[\\s|\\.]*', '', 'g'));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION current_district_name_for(p_id integer) RETURNS varchar AS $$
DECLARE
  name VARCHAR;
BEGIN
  select district_name into name from v_most_recent_roles where person_id = p_id limit 1;
  RETURN name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION current_party_for(p_id integer) RETURNS varchar AS $$
DECLARE
  p VARCHAR;
BEGIN
  select party into p from v_most_recent_roles where person_id = p_id limit 1;
  RETURN p;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION current_state_for(p_id integer) RETURNS varchar AS $$
DECLARE
  s INTEGER;
BEGIN
  select state_id into s from v_most_recent_roles where person_id = p_id limit 1;
  RETURN s;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION current_district_order_for(p_id integer) RETURNS varchar AS $$
DECLARE
  num VARCHAR;
BEGIN
  select district_order into num from v_most_recent_roles where person_id = p_id limit 1;
  RETURN num;
END;
$$ LANGUAGE plpgsql;

-- FOREIGN KEY CONSTRAINTS --
ALTER TABLE districts
ADD CONSTRAINT districts_state_fk
FOREIGN KEY (state_id) REFERENCES states (id);

ALTER TABLE legislatures
 ADD CONSTRAINT legislatures_state_fk
 FOREIGN KEY (state_id) REFERENCES states (id);

ALTER TABLE chambers
  ADD CONSTRAINT chamber_legislature_fk
  FOREIGN KEY (legislature_id) REFERENCES legislatures (id);

ALTER TABLE sessions
 ADD CONSTRAINT session_legislature_fk
 FOREIGN KEY (legislature_id) REFERENCES legislatures (id);

ALTER TABLE roles
 ADD CONSTRAINT role_person_fk
 FOREIGN KEY (person_id) REFERENCES people (id);

ALTER TABLE roles
 ADD CONSTRAINT role_state_fk
 FOREIGN KEY (state_id) REFERENCES states (id);

ALTER TABLE roles
 ADD CONSTRAINT role_district_fk
 FOREIGN KEY (district_id) REFERENCES districts (id);

ALTER TABLE roles
 ADD CONSTRAINT role_chamber_fk
 FOREIGN KEY (chamber_id) REFERENCES chambers (id);

ALTER TABLE roles
 ADD CONSTRAINT role_session_fk
 FOREIGN KEY (session_id) REFERENCES sessions (id);

ALTER TABLE addresses
 ADD CONSTRAINT address_person_fk
 FOREIGN KEY (person_id) REFERENCES people (id);

ALTER TABLE votes
 ADD CONSTRAINT votes_bill_id_fk
 FOREIGN KEY (bill_id) REFERENCES bills (id);

ALTER TABLE votes
 ADD CONSTRAINT votes_chamber_id_fk
 FOREIGN KEY (chamber_id) REFERENCES chambers (id);

ALTER TABLE committee_memberships
  ADD CONSTRAINT committee_membership_person_id_fk
  FOREIGN KEY (person_id) REFERENCES people (id);

ALTER TABLE committee_memberships
  ADD CONSTRAINT committee_membership_session_id_fk
  FOREIGN KEY (session_id) REFERENCES sessions (id);

ALTER TABLE committee_memberships
  ADD CONSTRAINT committee_membership_committee_id_fk
  FOREIGN KEY (committee_id) REFERENCES committees (id);

ALTER TABLE roll_calls
 ADD CONSTRAINT roll_calls_vote_id_fk
 FOREIGN KEY (vote_id) REFERENCES votes (id);

ALTER TABLE roll_calls
 ADD CONSTRAINT roll_calls_person_id_fk
 FOREIGN KEY (person_id) REFERENCES people (id);

ALTER TABLE contributions
 ADD CONSTRAINT contributions_business_id_fk
 FOREIGN KEY (business_id) REFERENCES businesses (id);

ALTER TABLE bills
 ADD CONSTRAINT bills_session_id_fk
 FOREIGN KEY (session_id) REFERENCES sessions (id);

ALTER TABLE bills
 ADD CONSTRAINT bills_chamber_id_fk
 FOREIGN KEY (chamber_id) REFERENCES chambers (id);

ALTER TABLE bill_versions
 ADD CONSTRAINT bill_versions_bill_id_fk
 FOREIGN KEY (bill_id) REFERENCES bills (id);

ALTER TABLE bill_sponsorships
 ADD CONSTRAINT bill_sponsorships_bill_id_fk
 FOREIGN KEY (bill_id) REFERENCES bills (id);

ALTER TABLE bill_documents
ADD CONSTRAINT bill_documents_bill_id_fk
FOREIGN KEY (bill_id) REFERENCES bills (id);

ALTER TABLE roles ADD CONSTRAINT party_ck CHECK (party in ('Democratic', 'Republican', 'Independent'));

-- UNIQUE CONSTRAINTS --
ALTER TABLE roles ADD CONSTRAINT person_session_unique UNIQUE (person_id, session_id);

-- INDEXES --
CREATE INDEX roll_calls_vote_id_and_type_idx ON roll_calls (vote_id, vote_type);

-- VIEWS --
DROP VIEW v_district_votes;
DROP VIEW v_roll_call_roles;
CREATE OR REPLACE VIEW v_roll_call_roles AS
select rc.id as roll_call_id, rc.vote_id, p.id as person_id, rc.vote_type, r.party, r.id as role_id, r.district_id, v.chamber_id, b.session_id
from
  roll_calls rc
  INNER JOIN people p ON (rc.person_id = p.id)
  INNER JOIN votes v ON (rc.vote_id = v.id)
  INNER JOIN bills b ON (b.id = v.bill_id)
  LEFT OUTER JOIN roles r ON (r.person_id = rc.person_id and b.session_id = r.session_id);

-- Used for geoserver vote maps
CREATE OR REPLACE VIEW v_district_votes AS
  select d.geom as the_geom, d.state_id, r.vote_id, r.party, r.vote_type, r.chamber_id, r.session_id
  from districts d, v_roll_call_roles r
  where d.id = r.district_id;

-- For each legislature, this grabs the most recent session for which there are roles
DROP VIEW v_most_recent_sessions;
CREATE OR REPLACE VIEW v_most_recent_sessions AS
  select recent.* from
    (select *, row_number() over (partition by legislature_id order by end_year desc) as rnum
    from sessions s
    where parent_id is null
    and exists (select id from roles r where r.session_id = s.id)) recent
  where recent.rnum = 1;

DROP VIEW v_most_recent_roles;
CREATE OR REPLACE VIEW v_most_recent_roles AS
  SELECT
    r.id as role_id,
    r.person_id,
    r.district_id,
    d.name as district_name,
    -- This is a simple order by for district numbers.
    CASE WHEN census_sld < 'A' 
           THEN lpad(census_sld, 3, '0')
           ELSE census_sld END as district_order,
    r.chamber_id,
    r.session_id,
    r.senate_class,
    r.party,
    r.created_at,
    r.updated_at,
    -- session years are inclusive on both ends
    coalesce(r.start_date, beginning_of(s.start_year)) as start_date,
    coalesce(r.end_date, end_of(s.end_year)) as end_date,
    coalesce(r.state_id, d.state_id) as state_id
  FROM
    (select *, row_number() over (partition by person_id order by end_date desc) as rnum
    from roles ro) r
    left outer join sessions s on (r.session_id = s.id)
    left outer join districts d on (d.id = r.district_id)
  where r.rnum = 1;

DROP VIEW v_tagged_actions;
DROP VIEW v_tagged_bills;
CREATE OR REPLACE VIEW v_tagged_bills AS
  select distinct t.name as tag_name, b.*
  from tags t, taggings tt, bills b, bills_subjects bs, subjects s
  where s.id = bs.subject_id and bs.bill_id = b.id and
  tt.taggable_type = 'Subject' and tt.taggable_id = s.id and
  tt.context = 'issues' and t.id = tt.tag_id;

CREATE OR REPLACE VIEW v_tagged_actions AS
  select distinct a.*, tgb.tag_name, tgb.state_id
  from v_tagged_bills as tgb, actions a
  where tgb.id = a.bill_id;

DROP VIEW v_tagged_sigs;
CREATE OR REPLACE VIEW v_tagged_sigs AS
  select distinct t.name as tag_name, sig.*
  from tags t, taggings tt, special_interest_groups sig, categories c
  where c.id = sig.category_id and
  tt.taggable_type = 'Category' and tt.taggable_id = c.id and
  tt.context = 'issues' and t.id = tt.tag_id;

-- Used for geoserver district maps.
-- Restricted by session_id, this view should alwyas show only
-- the people in that session who represent geographic districts (not senators)
DROP VIEW v_district_people;
CREATE OR REPLACE VIEW v_district_people AS
  select d.geom as the_geom, p.id as person_id, r.party, d.state_id, r.chamber_id
  from districts d, roles r, people p, sessions s
  where d.id = r.district_id
  and r.person_id = p.id
  and s.id = r.session_id;

-- Given that bill numbers can come into the system
-- as "AB 2818" or "H.R.1282", this index allows us to do bill number
-- lookups in a consistent fashion.
drop index bill_number_idx;
create index bill_number_idx on bills (upper_and_stripped(bill_number));
