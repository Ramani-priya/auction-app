# frozen_string_literal: true

class CreateBidHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :bid_histories do |t|
      t.references :bid, null: false, foreign_key: true
      t.references :auction, null: false, foreign_key: true
      t.decimal :previous_bid_price, precision: 12, scale:
      2
      t.decimal :current_bid_price, precision: 12, scale: 2, null: false
      t.decimal :previous_max_bid_price, precision: 12, scale: 2
      t.decimal :current_max_bid_price, precision: 12, scale: 2, null: false
      t.boolean :system_generated, default: false
      t.timestamps
    end
  end
end
