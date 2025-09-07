# frozen_string_literal: true

class CreateBids < ActiveRecord::Migration[7.0]
  def change
    create_table :bids do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :current_bid_price, precision: 12, scale: 2, null: false
      t.decimal :max_bid_price, precision: 12, scale: 2
      t.boolean :autobid, null: false, default: false
      t.boolean :system_generated, null: false, default: false
      t.integer :status, null: false, default: 1
      t.timestamps
    end
  end
end
