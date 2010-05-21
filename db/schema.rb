# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 28) do

  create_table "actions", :force => true do |t|
    t.integer  "bill_id"
    t.datetime "date"
    t.string   "actor"
    t.string   "actor_type"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", :force => true do |t|
    t.integer  "person_id",      :null => false
    t.string   "line_one"
    t.string   "line_two"
    t.string   "city"
    t.integer  "state_id"
    t.string   "postal_code"
    t.string   "votesmart_type"
    t.string   "phone_one"
    t.string   "phone_two"
    t.string   "fax_one"
    t.string   "fax_two"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bills", :force => true do |t|
    t.string   "title",              :limit => 1000
    t.integer  "state_id"
    t.integer  "session_id"
    t.string   "fiftystates_id"
    t.string   "bill_number"
    t.integer  "chamber_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "first_action_at"
    t.datetime "last_action_at"
    t.boolean  "votesmart_key_vote",                 :default => false, :null => false
  end

  create_table "chambers", :force => true do |t|
    t.integer "legislature_id"
    t.string  "type"
    t.string  "title"
    t.string  "name"
    t.integer "term_length"
  end

  create_table "committee_memberships", :force => true do |t|
    t.integer "person_id"
    t.integer "session_id"
    t.integer "committee_id"
  end

  create_table "committees", :force => true do |t|
    t.string   "name",                             :null => false
    t.integer  "votesmart_parent_id"
    t.integer  "votesmart_id"
    t.string   "votesmart_type_id",   :limit => 1
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legislature_id",                   :null => false
  end

  create_table "districts", :force => true do |t|
    t.string        "name",                                :null => false
    t.string        "census_sld"
    t.string        "census_district_type"
    t.boolean       "at_large"
    t.integer       "state_id",                            :null => false
    t.string        "vintage",              :limit => 4
    t.integer       "chamber_id"
    t.multi_polygon "geom",                 :limit => nil,                 :srid => 4269
  end

  add_index "districts", ["geom"], :name => "index_districts_on_geom", :spatial => true

  create_table "legislatures", :force => true do |t|
    t.string  "name"
    t.integer "state_id"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name",         :null => false
    t.string   "middle_name"
    t.string   "last_name",          :null => false
    t.integer  "fiftystates_id"
    t.integer  "nimsp_candidate_id"
    t.integer  "votesmart_id"
    t.integer  "govtrack_id"
    t.string   "metavid_id"
    t.string   "bioguide_id"
    t.string   "opensecrets_id"
    t.string   "youtube_id"
    t.string   "suffix"
    t.string   "religion"
    t.date     "birthday"
    t.string   "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "website_one"
    t.string   "website_two"
    t.string   "webmail"
    t.string   "email"
  end

  create_table "roles", :force => true do |t|
    t.integer  "person_id",    :null => false
    t.integer  "state_id"
    t.integer  "district_id"
    t.integer  "chamber_id"
    t.integer  "session_id"
    t.integer  "senate_class"
    t.string   "party"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roll_calls", :force => true do |t|
    t.integer  "vote_id"
    t.integer  "person_id"
    t.string   "vote_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.integer  "legislature_id"
    t.integer  "start_year"
    t.integer  "end_year"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsorships", :force => true do |t|
    t.integer  "bill_id"
    t.integer  "sponsor_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "name",                                        :null => false
    t.string   "abbrev",      :limit => 2,                    :null => false
    t.boolean  "unicameral",               :default => false
    t.integer  "fips_code"
    t.datetime "launch_date"
  end

  create_table "subscriptions", :force => true do |t|
    t.string   "email"
    t.integer  "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "versions", :force => true do |t|
    t.integer  "bill_id"
    t.string   "url"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes", :force => true do |t|
    t.integer  "yes_count"
    t.integer  "no_count"
    t.integer  "other_count"
    t.integer  "bill_id"
    t.datetime "date"
    t.boolean  "passed"
    t.integer  "chamber_id"
    t.string   "fiftystates_id"
    t.string   "motion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
