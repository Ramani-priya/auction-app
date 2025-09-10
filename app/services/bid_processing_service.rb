# frozen_string_literal: true

class BidProcessingService
  def initialize(bid)
    @bid = bid
    @auction = bid.auction
  end

  def call
    process_bid
  end

  private

  def process_bid
    update_auction_highest_bid
    outdate_user_previous_bids
  end

  def update_auction_highest_bid
    @auction.update!(current_highest_bid_id: @bid.id)
  end

  def outdate_user_previous_bids
    old_bid = @auction.bids.where(user_id: @bid.user_id).where.not(id: @bid.id).last
    old_bid.outdate! if old_bid&.may_outdate?
  end
end
