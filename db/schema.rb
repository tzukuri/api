# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160621052859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  add_index "admin_users", ["unlock_token"], name: "index_admin_users_on_unlock_token", unique: true, using: :btree

  create_table "api_devices", force: :cascade do |t|
    t.string   "token_id"
    t.string   "launch_language"
    t.string   "preferred_language"
    t.string   "locale"
    t.string   "name"
    t.string   "os"
    t.string   "device_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "apps", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "token_id"
    t.string   "private_key"
    t.string   "callback_url"
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "app_id"
    t.string   "token"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "email"
    t.datetime "revoked"
    t.string   "reason"
    t.integer  "api_device_id"
    t.string   "apns_token"
    t.string   "app_version"
    t.string   "diagnostics_sync_token"
  end

  create_table "beta_identities", force: :cascade do |t|
    t.integer  "beta_user_id"
    t.string   "provider"
    t.string   "access_token"
    t.string   "private_token"
    t.string   "uid"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "beta_identities", ["beta_user_id"], name: "index_beta_identities_on_beta_user_id", using: :btree

  create_table "beta_orders", force: :cascade do |t|
    t.integer  "beta_user_id"
    t.string   "address1"
    t.string   "address2"
    t.string   "state"
    t.string   "postcode"
    t.string   "country"
    t.string   "frame"
    t.string   "size"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "phone"
  end

  add_index "beta_orders", ["beta_user_id"], name: "index_beta_orders_on_beta_user_id", using: :btree

  create_table "beta_questions", force: :cascade do |t|
    t.string   "content"
    t.integer  "point_value"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "precondition_id"
  end

  create_table "beta_referrals", force: :cascade do |t|
    t.integer  "inviter_id"
    t.integer  "invitee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "beta_responses", force: :cascade do |t|
    t.integer  "beta_user_id"
    t.integer  "beta_question_id"
    t.string   "response"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "beta_users", force: :cascade do |t|
    t.string   "email",        default: "",    null: false
    t.string   "name"
    t.string   "invite_token"
    t.float    "score",        default: 0.0
    t.boolean  "selected",     default: false
    t.string   "user_agent"
    t.string   "ip_address"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.date     "birth_date"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "city"
  end

  add_index "beta_users", ["email"], name: "index_beta_users_on_email", unique: true, using: :btree
  add_index "beta_users", ["invite_token"], name: "index_beta_users_on_invite_token", using: :btree
  add_index "beta_users", ["score"], name: "index_beta_users_on_score", using: :btree

  create_table "betareservations", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "address1"
    t.string   "address2"
    t.string   "state"
    t.string   "postcode"
    t.string   "country"
    t.string   "frame"
    t.string   "colour"
    t.string   "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "model"
  end

  create_table "devices", force: :cascade do |t|
    t.string   "mac_address"
    t.string   "design"
    t.string   "size"
    t.string   "colour"
    t.datetime "frame_manufacture_ts"
    t.datetime "hardware_manufacture_ts"
    t.string   "hardware_revision"
    t.string   "frame_revision"
    t.string   "firmware_revision"
    t.datetime "charge_qc_pass_ts"
    t.datetime "rf_qc_pass_ts"
    t.datetime "shipped"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "charger_revision"
    t.string   "serial"
    t.integer  "pin"
    t.integer  "state",                       default: 0
    t.integer  "state_set_by_auth_token_id"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "coords_set_by_auth_token_id"
    t.integer  "coords_set_at"
    t.integer  "state_set_at"
    t.boolean  "optical"
  end

  add_index "devices", ["serial"], name: "index_devices_on_serial", unique: true, using: :btree

  create_table "emails", force: :cascade do |t|
    t.string   "email"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_entries", force: :cascade do |t|
    t.integer  "auth_token_id"
    t.datetime "created_at"
    t.string   "type"
    t.string   "data"
  end

  add_index "log_entries", ["auth_token_id", "created_at", "type"], name: "index_log_entries_on_auth_token_id_and_created_at_and_type", order: {"created_at"=>:desc}, using: :btree

  create_table "ownerships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "device_id"
    t.datetime "revoked"
    t.string   "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchases", force: :cascade do |t|
    t.string   "email"
    t.string   "frame"
    t.string   "colour"
    t.string   "size"
    t.string   "customer_id"
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "postcode"
    t.string   "country"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "charge_id"
  end

  create_table "que_jobs", id: false, force: :cascade do |t|
    t.integer  "priority",    limit: 2, default: 100,                                        null: false
    t.datetime "run_at",                default: "now()",                                    null: false
    t.integer  "job_id",      limit: 8, default: "nextval('que_jobs_job_id_seq'::regclass)", null: false
    t.text     "job_class",                                                                  null: false
    t.json     "args",                  default: [],                                         null: false
    t.integer  "error_count",           default: 0,                                          null: false
    t.text     "last_error"
    t.text     "queue",                 default: "",                                         null: false
  end

  create_table "quietzones", force: :cascade do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "radius"
    t.time     "starttime"
    t.time     "endtime"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "quietzones", ["user_id"], name: "index_quietzones_on_user_id", using: :btree

  create_table "recordings", force: :cascade do |t|
    t.integer  "device_id"
    t.integer  "room_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.datetime "recording_date"
  end

  add_index "recordings", ["device_id"], name: "index_recordings_on_device_id", using: :btree
  add_index "recordings", ["room_id"], name: "index_recordings_on_room_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.string   "name"
    t.integer  "quietzone_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "rooms", ["quietzone_id"], name: "index_rooms_on_quietzone_id", using: :btree

  create_table "rsvps", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "inviter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.integer  "confirmed_tc_version"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  add_foreign_key "beta_identities", "beta_users"
  add_foreign_key "beta_orders", "beta_users"
  add_foreign_key "quietzones", "users"
  add_foreign_key "recordings", "devices"
  add_foreign_key "recordings", "rooms", on_delete: :cascade
  add_foreign_key "rooms", "quietzones", on_delete: :cascade
end
