# frozen_string_literal: true

class SoldAuctionService
  def initialize(auction)
    @auction = auction
  end

  def call
    return unless @auction.current_highest_bid
    if @auction.current_highest_bid.current_bid_price < @auction.min_selling_price
      return
    end

    ActiveRecord::Base.transaction do
      create_auction_result({
                              winning_bid: @auction.current_highest_bid,
                              winner: @auction.current_highest_bid.user,
                              final_price: @auction.current_highest_bid.current_bid_price,
                            })
      @auction.current_highest_bid.win!
      NotifyWinnerJob.perform_async(@auction.id)
    end
  end

  private

  def create_auction_result(params)
    AuctionResult.create(params.merge(auction: @auction))
  end
end
