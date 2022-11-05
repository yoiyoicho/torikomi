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

ActiveRecord::Schema[7.0].define(version: 2022_11_05_114709) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "google_calendar_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "monday", default: false, null: false
    t.boolean "tuesday", default: false, null: false
    t.boolean "wednesday", default: false, null: false
    t.boolean "thursday", default: false, null: false
    t.boolean "friday", default: false, null: false
    t.boolean "saturday", default: false, null: false
    t.boolean "sunday", default: false, null: false
    t.integer "start_time_hour", default: 0, null: false
    t.integer "start_time_min", default: 0, null: false
    t.integer "end_time_hour", default: 23, null: false
    t.integer "end_time_min", default: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_google_calendar_settings_on_user_id", unique: true
  end

  create_table "google_calendar_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "refresh_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_calendar_id", null: false
    t.index ["user_id"], name: "index_google_calendar_tokens_on_user_id", unique: true
  end

  create_table "line_users", force: :cascade do |t|
    t.string "line_user_id", null: false
    t.string "display_name", null: false
    t.string "picture_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_user_id"], name: "index_line_users_on_line_user_id", unique: true
  end

  create_table "link_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_link_tokens_on_user_id"
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
    t.integer "resource_type", default: 0, null: false
    t.string "i_cal_uid"
    t.datetime "sent_at"
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "message_option", default: 1, null: false
    t.string "message_text", limit: 255
    t.integer "notification_time", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_settings_on_user_id", unique: true
  end

  create_table "user_line_user_relationships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "line_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_user_id"], name: "index_user_line_user_relationships_on_line_user_id"
    t.index ["user_id"], name: "index_user_line_user_relationships_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "login_type", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.integer "role", default: 0, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "google_calendar_settings", "users"
  add_foreign_key "google_calendar_tokens", "users"
  add_foreign_key "link_tokens", "users"
  add_foreign_key "schedules", "users"
  add_foreign_key "settings", "users"
  add_foreign_key "user_line_user_relationships", "line_users"
  add_foreign_key "user_line_user_relationships", "users"
end
