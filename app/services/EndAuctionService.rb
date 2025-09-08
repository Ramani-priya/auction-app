class EndAuctionService
  def initialize(auction)
    @auction = auction
  end

  def call
    return unless @auction.active? && @auction.end_time <= Time.current
    ActiveRecord::Base.transaction do
      @auction.end_auction!
    rescue StandardError => e
      Rails.logger.error("Failed to end auction #{@auction.id}: #{e.message}")
    end
  end
end