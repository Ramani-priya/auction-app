# frozen_string_literal: true

FactoryBot.define do
  factory :auction do
    item
    description { 'MyText' }
    seller factory: %i[user]
    starting_price { 50.00 }
    min_selling_price { 75.00 }
    start_time { 1.day.ago }
    end_time { 1.day.from_now }
    status { 'active' }
  end
end
