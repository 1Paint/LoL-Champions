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

ActiveRecord::Schema.define(version: 20160501010255) do

  create_table "champions", force: :cascade do |t|
    t.string   "champ_name_id"
    t.string   "champ_key"
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "attack"
    t.integer  "defense"
    t.integer  "magic"
    t.integer  "difficulty"
    t.string   "version"
    t.string   "hpmin"
    t.string   "hpregenmin"
    t.string   "mpmin"
    t.string   "mpregenmin"
    t.string   "movespeedmin"
    t.string   "armormin"
    t.string   "spellblockmin"
    t.string   "attackdamagemin"
    t.string   "attackspeedmin"
    t.string   "attackrangemin"
    t.string   "hpmax"
    t.string   "hpregenmax"
    t.string   "mpmax"
    t.string   "mpregenmax"
    t.string   "movespeedmax"
    t.string   "armormax"
    t.string   "spellblockmax"
    t.string   "attackdamagemax"
    t.string   "attackspeedmax"
    t.string   "attackrangemax"
    t.string   "primary"
    t.string   "secondary"
    t.string   "missing_q"
    t.string   "missing_w"
    t.string   "missing_e"
    t.string   "missing_r"
    t.boolean  "bad_passive"
  end

  add_index "champions", ["champ_name_id"], name: "index_champions_on_champ_name_id"

end
