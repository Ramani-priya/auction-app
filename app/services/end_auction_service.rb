# frozen_string_literal: true

class EndAuctionService
  def initialize(auction)
    @auction = auction
  end

  def call
    return unless should_end_auction?

    begin
      ActiveRecord::Base.transaction do
        @auction.end_auction!
      end
      true
    rescue StandardError => e
      Rails.logger.error("Failed to end auction #{@auction.id}: #{e.message}")
      false
    end
  end

  private

  def should_end_auction?
    @auction.active? && @auction.end_time <= Time.current
  end
end

