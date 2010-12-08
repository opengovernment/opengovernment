# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 71) do

  create_table "actions", :force => true do |t|
    t.integer  "bill_id"
    t.datetime "date"
    t.string   "actor"
    t.string   "action",        :limit => 10000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action_number"
    t.string   "kind_one"
    t.string   "kind_two"
    t.string   "kind_three"
  end

  add_index "actions", ["bill_id", "date"], :name => "index_actions_on_bill_id_and_date"

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

  create_table "bill_documents", :force => true do |t|
    t.integer  "bill_id"
    t.string   "name",                  :limit => 4000
    t.string   "url",                   :limit => 8000
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
  end

  create_table "bill_sponsorships", :force => true do |t|
    t.integer  "bill_id"
    t.integer  "sponsor_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sponsor_name"
  end

  create_table "bill_versions", :force => true do |t|
    t.integer  "bill_id"
    t.string   "url"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
  end

  create_table "bills", :force => true do |t|
    t.string   "title",              :limit => 64000
    t.integer  "state_id"
    t.integer  "session_id"
    t.string   "openstates_id"
    t.string   "bill_number"
    t.integer  "chamber_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "votesmart_key_vote",                  :default => false, :null => false
    t.integer  "votesmart_id"
    t.datetime "first_action_at"
    t.datetime "last_action_at"
    t.string   "kind_one"
    t.string   "kind_two"
    t.string   "kind_three"
    t.string   "alternate_titles",   :limit => 20000
    t.string   "short_title",        :limit => 1000
  end

  create_table "bills_subjects", :force => true do |t|
    t.integer  "bill_id"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "votesmart_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chambers", :force => true do |t|
    t.integer "legislature_id"
    t.string  "type"
    t.string  "title"
    t.string  "name"
    t.integer "term_length"
  end

  create_table "citations", :force => true do |t|
    t.integer  "citeable_id"
    t.string   "citeable_type"
    t.datetime "retrieved"
    t.string   "url"
  end

  create_table "committee_memberships", :force => true do |t|
    t.integer "person_id"
    t.integer "session_id"
    t.integer "committee_id"
    t.string  "full_name"
    t.string  "role"
  end

  create_table "committees", :force => true do |t|
    t.string   "name",                                                      :null => false
    t.integer  "votesmart_parent_id"
    t.integer  "votesmart_id"
    t.string   "votesmart_type_id",   :limit => 1
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legislature_id",                                            :null => false
    t.string   "type",                             :default => "Committee", :null => false
    t.string   "openstates_id"
    t.integer  "parent_id"
  end

  create_table "contributions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "business_id"
    t.integer  "contributor_state_id"
    t.string   "contributor_occupation"
    t.string   "contributor_employer"
    t.integer  "amount"
    t.date     "date"
    t.string   "contributor_city"
    t.string   "contributor_name"
    t.string   "contributor_zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state_id"
  end

  create_table "corporate_entities", :force => true do |t|
    t.string   "name"
    t.integer  "nimsp_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "sector_id"
    t.integer  "industry_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "legislatures", :force => true do |t|
    t.string  "name"
    t.integer "state_id"
  end

  create_table "mentions", :force => true do |t|
    t.string   "url",           :limit => 8000
    t.string   "excerpt",       :limit => 4000
    t.string   "title",         :limit => 1000
    t.string   "source"
    t.datetime "date"
    t.float    "weight"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "search_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mentions", ["owner_id", "owner_type", "date"], :name => "citations_owner_date_idx"

  create_table "people", :force => true do |t|
    t.string   "first_name",                          :null => false
    t.string   "middle_name"
    t.string   "last_name",                           :null => false
    t.string   "openstates_id"
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
    t.string   "website_one",         :limit => 2000
    t.string   "website_two",         :limit => 2000
    t.string   "webmail",             :limit => 2000
    t.string   "email"
    t.string   "photo_url"
    t.string   "bio_data",            :limit => 8000
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "transparencydata_id"
  end

  create_table "ratings", :force => true do |t|
    t.integer  "person_id"
    t.string   "rating"
    t.integer  "timespan"
    t.integer  "sig_id"
    t.integer  "votesmart_id"
    t.string   "rating_text",  :limit => 4000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rating_name"
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

  add_index "roles", ["person_id", "session_id"], :name => "person_session_unique", :unique => true

  create_table "roll_calls", :force => true do |t|
    t.integer  "vote_id"
    t.integer  "person_id"
    t.string   "vote_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "committee"
    t.float    "threshold"
  end

  add_index "roll_calls", ["person_id"], :name => "roll_calls_person_id_idx"
  add_index "roll_calls", ["vote_id", "vote_type"], :name => "roll_calls_vote_id_and_type_idx"

  create_table "sessions", :force => true do |t|
    t.integer  "legislature_id"
    t.integer  "start_year"
    t.integer  "end_year"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "special_interest_groups", :force => true do |t|
    t.integer  "state_id"
    t.integer  "category_id"
    t.string   "name"
    t.string   "description",  :limit => 4000
    t.string   "contact_name"
    t.string   "city"
    t.string   "address"
    t.string   "zip"
    t.string   "url"
    t.string   "phone_one"
    t.integer  "votesmart_id"
    t.string   "phone_two"
    t.string   "email"
    t.string   "fax"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "name",                                         :null => false
    t.string   "abbrev",       :limit => 2,                    :null => false
    t.boolean  "unicameral",                :default => false
    t.integer  "fips_code"
    t.datetime "launch_date"
    t.string   "official_url"
  end

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
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
    t.string   "openstates_id"
    t.string   "motion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
    t.string   "committee_name"
    t.float    "threshold"
  end

end
