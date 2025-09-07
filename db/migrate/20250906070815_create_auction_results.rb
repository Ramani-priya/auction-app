# frozen_string_literal: true

class CreateAuctionResults < ActiveRecord::Migration[7.0]
  def change
    create_table :auction_results do |t|
      t.references :auction, null: false, foreign_key: true
      t.references :winning_bid, null: false, foreign_key: { to_table: :bids }
      t.references :winner, null: false, foreign_key: { to_table: :users }
      t.decimal :final_price, precision: 12, scale: 2, null: false
      t.timestamps
    end
  end
end
