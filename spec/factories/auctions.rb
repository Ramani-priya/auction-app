# frozen_string_literal: true

FactoryBot.define do
  factory :auction do
    association :item
    association :seller, factory: :user
    association :current_highest_bid, factory: :bid
    starting_price { 50.00 }
    min_selling_price { 75.00 }
    start_time { 1.day.ago }
    end_time { 1.day.from_now }
    status { 'active' }
    # Add other required fields as needed
  end
end
