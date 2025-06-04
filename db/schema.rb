# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_04_115612) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "promo_codes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.jsonb "advantage", default: {}, null: false
    t.index ["name"], name: "index_promo_codes_on_name", unique: true
  end

  create_table "restriction_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "operator", default: "and", null: false
    t.string "restrictable_type", null: false
    t.bigint "restrictable_id", null: false
    t.index ["restrictable_type", "restrictable_id"], name: "index_restriction_groups_on_restrictable"
  end

  create_table "restrictions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.bigint "restriction_group_id", null: false
    t.jsonb "conditions", default: {}, null: false
    t.index ["restriction_group_id"], name: "index_restrictions_on_restriction_group_id"
    t.index ["type"], name: "index_restrictions_on_type"
  end
end
