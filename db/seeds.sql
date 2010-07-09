-- Any executes from migrations must go in here, or they
-- will not be run when someone installs the app.

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

CREATE OR REPLACE VIEW v_district_votes AS
  select d.geom as the_geom, rc.vote_id, p.id as person_id, rc.vote_type, r.party, d.state_id, v.chamber_id
  from districts d, roles r, roll_calls rc, people p, votes v
  where d.id = r.district_id
  and rc.person_id = p.id
  and r.person_id = p.id
  and v.id = rc.vote_id
  and v.date between r.start_date and r.end_date;

CREATE OR REPLACE VIEW v_district_people AS
  select d.geom as the_geom, p.id as person_id, r.party, d.state_id, r.chamber_id
  from districts d, roles r, people p
  where d.id = r.district_id
  and r.person_id = p.id
  and current_date between r.start_date and r.end_date;
