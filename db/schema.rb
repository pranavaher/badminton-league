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

ActiveRecord::Schema[8.1].define(version: 2026_02_18_131000) do
  create_table "matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "loser_id"
    t.string "name"
    t.integer "player_a_id"
    t.integer "player_b_id"
    t.datetime "updated_at", null: false
    t.integer "winner_id"
    t.index ["loser_id"], name: "index_matches_on_loser_id"
    t.index ["player_a_id"], name: "index_matches_on_player_a_id"
    t.index ["player_b_id"], name: "index_matches_on_player_b_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "updated_at", null: false
    t.index ["last_name", "first_name"], name: "index_players_on_last_name_and_first_name"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "matches", "players", column: "loser_id"
  add_foreign_key "matches", "players", column: "player_a_id"
  add_foreign_key "matches", "players", column: "player_b_id"
  add_foreign_key "matches", "players", column: "winner_id"
end
