# frozen_string_literal: true

FactoryBot.define do
  factory :auction_result do
    auction
    winning_bid factory: %i[bid]
    winner factory: %i[user]
    final_price { winning_bid.current_bid_price }
  end
end
