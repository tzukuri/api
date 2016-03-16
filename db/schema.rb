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

ActiveRecord::Schema.define(version: 20160316015309) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beta_reservations", force: true do |t|
    t.string   "email"
    t.string   "frame"
    t.string   "colour"
    t.string   "size"
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "postcode"
    t.string   "country"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", force: true do |t|
    t.string   "email"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchases", force: true do |t|
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

  create_table "rsvps", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "inviter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
