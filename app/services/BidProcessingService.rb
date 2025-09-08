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
    ActiveRecord::Base.transaction do
      update_auction_highest_bid
      outdate_user_previous_bids
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to process bid #{@bid.id}: #{e.message}")
    raise e
  rescue StandardError => e
    Rails.logger.error("Unexpected error processing bid #{@bid.id}: #{e.class} - #{e.message}")
    raise e
  end

  private

  def update_auction_highest_bid
    @auction.update!(current_highest_bid_id: @bid.id)
  end

  def outdate_user_previous_bids
    @auction.bids.where(user_id: @bid.user_id).where.not(id: @bid.id).each do |bid|
      bid.outdate! if bid.may_outdate?
    end
  end
end