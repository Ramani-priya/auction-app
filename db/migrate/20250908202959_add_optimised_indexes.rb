# frozen_string_literal: true

class AddOptimisedIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :bids, %i[user_id status],
              name: 'index_bids_on_user_id_and_status'
    add_index :bids,
              %i[auction_id status autobid max_bid_price created_at], name: 'index_bids_on_auction_status_autobid_maxbid_created'
    add_index :auctions, %i[status end_time],
              name: 'index_auctions_on_status_and_end_time'
    add_index :auctions, %i[seller_id status],
              name: 'index_auctions_on_seller_id_and_status'
  end
end
