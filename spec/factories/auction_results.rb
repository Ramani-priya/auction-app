# frozen_string_literal: true

FactoryBot.define do
  factory :auction_result do
    association :auction
    association :winning_bid, factory: :bid
    association :winner, factory: :user
    final_price { winning_bid.current_bid_price }
  end
end
