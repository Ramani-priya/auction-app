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

ActiveRecord::Schema[7.0].define(version: 2025_09_08_202959) do
  create_table "auction_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "auction_id", null: false
    t.bigint "winning_bid_id", null: false
    t.bigint "winner_id", null: false
    t.decimal "final_price", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_auction_results_on_auction_id"
    t.index ["winner_id"], name: "index_auction_results_on_winner_id"
    t.index ["winning_bid_id"], name: "index_auction_results_on_winning_bid_id"
  end

  create_table "auctions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "seller_id", null: false
    t.decimal "starting_price", precision: 10, scale: 2, null: false
    t.decimal "min_selling_price", precision: 10, scale: 2, null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "current_highest_bid_id"
    t.integer "lock_version", default: 0, null: false
    t.index ["current_highest_bid_id"], name: "index_auctions_on_current_highest_bid_id"
    t.index ["item_id"], name: "index_auctions_on_item_id"
    t.index ["seller_id", "status"], name: "index_auctions_on_seller_id_and_status"
    t.index ["seller_id"], name: "index_auctions_on_seller_id"
    t.index ["status", "end_time"], name: "index_auctions_on_status_and_end_time"
  end

  create_table "bid_histories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "bid_id", null: false
    t.bigint "auction_id", null: false
    t.decimal "previous_bid_price", precision: 12, scale: 2
    t.decimal "current_bid_price", precision: 12, scale: 2, null: false
    t.decimal "previous_max_bid_price", precision: 12, scale: 2
    t.decimal "current_max_bid_price", precision: 12, scale: 2, null: false
    t.boolean "system_generated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_bid_histories_on_auction_id"
    t.index ["bid_id"], name: "index_bid_histories_on_bid_id"
  end

  create_table "bids", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "auction_id", null: false
    t.bigint "user_id", null: false
    t.decimal "current_bid_price", precision: 12, scale: 2, null: false
    t.decimal "max_bid_price", precision: 12, scale: 2
    t.boolean "autobid", default: false, null: false
    t.boolean "system_generated", default: false, null: false
    t.integer "status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "parent_id"
    t.index ["auction_id", "status", "autobid", "max_bid_price", "created_at"], name: "index_bids_on_auction_status_autobid_maxbid_created"
    t.index ["auction_id"], name: "index_bids_on_auction_id"
    t.index ["parent_id"], name: "index_bids_on_parent_id"
    t.index ["user_id", "status"], name: "index_bids_on_user_id_and_status"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "auction_results", "auctions"
  add_foreign_key "auction_results", "bids", column: "winning_bid_id"
  add_foreign_key "auction_results", "users", column: "winner_id"
  add_foreign_key "auctions", "bids", column: "current_highest_bid_id"
  add_foreign_key "auctions", "items"
  add_foreign_key "auctions", "users", column: "seller_id"
  add_foreign_key "bid_histories", "auctions"
  add_foreign_key "bid_histories", "bids"
  add_foreign_key "bids", "auctions"
  add_foreign_key "bids", "bids", column: "parent_id"
  add_foreign_key "bids", "users"
end
