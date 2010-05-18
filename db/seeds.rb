# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
execute "ALTER TABLE districts
ADD CONSTRAINT districts_state_fk
FOREIGN KEY (state_id) REFERENCES states (id);"

execute "ALTER TABLE legislatures
 ADD CONSTRAINT legislatures_state_fk
 FOREIGN KEY (state_id) REFERENCES states (id);"

execute "ALTER TABLE chambers
  ADD CONSTRAINT chamber_legislature_fk
  FOREIGN KEY (legislature_id) REFERENCES legislatures (id);"

execute "ALTER TABLE sessions
 ADD CONSTRAINT session_legislature_fk
 FOREIGN KEY (legislature_id) REFERENCES legislatures (id);"

execute "ALTER TABLE roles
 ADD CONSTRAINT role_person_fk
 FOREIGN KEY (person_id) REFERENCES people (id);"

execute "ALTER TABLE roles
 ADD CONSTRAINT role_state_fk
 FOREIGN KEY (state_id) REFERENCES states (id);"

execute "ALTER TABLE roles
 ADD CONSTRAINT role_district_fk
 FOREIGN KEY (district_id) REFERENCES districts (id);"

execute "ALTER TABLE roles
 ADD CONSTRAINT role_chamber_fk
 FOREIGN KEY (chamber_id) REFERENCES chambers (id);"

execute "ALTER TABLE roles
 ADD CONSTRAINT role_session_fk
 FOREIGN KEY (session_id) REFERENCES sessions (id);"

execute "ALTER TABLE addresses
 ADD CONSTRAINT address_person_fk
 FOREIGN KEY (person_id) REFERENCES people (id);"
