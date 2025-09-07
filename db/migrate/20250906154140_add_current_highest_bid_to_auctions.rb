# frozen_string_literal: true

class AddCurrentHighestBidToAuctions < ActiveRecord::Migration[7.0]
  def change
    add_reference :auctions, :current_highest_bid,
                  foreign_key: { to_table: :bids }, null: true
  end
end
