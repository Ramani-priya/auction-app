# frozen_string_literal: true

class SoldAuctionService
  def initialize(auction)
    @auction = auction
  end

  def call
    return unless @auction.current_highest_bid
    return if @auction.current_highest_bid.current_bid_price < min_selling_price

    ActiveRecord::Base.transaction do
      create_auction_result(
        winning_bid: current_highest_bid,
        winner: current_highest_bid.user,
        final_price: current_highest_bid.current_bid_price,
      )
      current_highest_bid.win!
      NotifyWinnerJob.perform_async(id)
    end
  end

  private

  
end
