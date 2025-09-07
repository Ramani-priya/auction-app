# frozen_string_literal: true

class AuctionResult < ApplicationRecord
  belongs_to :auction
  belongs_to :winning_bid, class_name: 'Bid'
  belongs_to :winner, class_name: 'User'
end
