-- Any executes from migrations must go in here, or they
-- will not be run when someone installs the app.

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

ALTER TABLE versions
 ADD CONSTRAINT versions_bill_id_fk
 FOREIGN KEY (bill_id) REFERENCES bills (id);

ALTER TABLE sponsorships
 ADD CONSTRAINT sponsorships_bill_id_fk
 FOREIGN KEY (bill_id) REFERENCES bills (id);


-- UNIQUE CONSTRAINTS --
ALTER TABLE roles ADD CONSTRAINT person_session_unique UNIQUE (person_id, session_id);

-- INDEXES --
CREATE INDEX roll_calls_vote_id_and_type_idx ON roll_calls (vote_id, vote_type);

-- VIEWS --
DROP VIEW v_roll_call_roles;
CREATE OR REPLACE VIEW v_roll_call_roles AS
select rc.id as roll_call_id, rc.vote_id, p.id as person_id, rc.vote_type, r.party, r.id as role_id, r.district_id, v.chamber_id, b.session_id
from
  roll_calls rc
  INNER JOIN people p ON (rc.person_id = p.id)
  INNER JOIN votes v ON (rc.vote_id = v.id)
  INNER JOIN bills b ON (b.id = v.bill_id)
  LEFT OUTER JOIN roles r ON (r.person_id = rc.person_id and b.session_id = r.session_id);

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
  SELECT r.id as role_id, r.person_id, r.district_id, r.chamber_id, r.session_id, r.senate_class, r.party, r.start_date, r.end_date, r.created_at, r.updated_at, coalesce(r.state_id, d.state_id) as state_id
  FROM
    (select *, row_number() over (partition by person_id order by end_date desc) as rnum
    from roles ro) r
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
  select distinct a.*, tag_name
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

-- Used for geoserver vote maps
DROP VIEW v_district_votes;
CREATE OR REPLACE VIEW v_district_votes AS
  select d.geom as the_geom, d.state_id, r.vote_id, r.party, r.vote_type, r.chamber_id, r.session_id
  from districts d, v_roll_call_roles r
  where d.id = r.district_id;
