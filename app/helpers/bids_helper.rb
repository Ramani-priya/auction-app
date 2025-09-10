# frozen_string_literal: true

module BidsHelper
  def bid_price(bid)
    "Your Bid: $#{number_with_precision(bid.current_bid_price, precision: 2)}"
  end

  def bid_description(bid)
    "Placed on #{bid.created_at.strftime('%b %d, %Y at %I:%M %p')}"
  end

  def current_bid_value(auction)
    auction.current_highest_bid&.current_bid_price || auction.starting_price
  end
end
