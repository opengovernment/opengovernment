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
