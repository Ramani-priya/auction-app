# frozen_string_literal: true

FactoryBot.define do
  factory :bid do
    user
    auction
    current_bid_price { 100 }
    max_bid_price { 200 }
    status { :active }
    autobid { false }
    system_generated { false }
  end
end
