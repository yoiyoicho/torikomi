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

ActiveRecord::Schema[7.0].define(version: 2022_07_23_100832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "line_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "line_user_id", null: false
    t.string "display_name", null: false
    t.string "picture_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["user_id"], name: "index_line_users_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", limit: 255, null: false
    t.string "body", limit: 65535
    t.datetime "start_time", precision: nil, null: false
    t.datetime "end_time", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_id", default: "", null: false
    t.integer "status", default: 0, null: false
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "message_option", default: 0, null: false
    t.string "message_text", limit: 255
    t.integer "notification_time", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_settings_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "line_users", "users"
  add_foreign_key "schedules", "users"
  add_foreign_key "settings", "users"
end
