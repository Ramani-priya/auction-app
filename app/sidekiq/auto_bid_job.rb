require 'auction_errors'
class AutoBidJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 5

  def perform(auction_id)
    AutoBidService.new(auction_id).call
  rescue AuctionErrors::AuctionInactiveError => e
    Rails.logger.info "AutoBidJob skipped: #{e.message}"
  rescue AuctionErrors::AuctionBidCreationError => e
    Rails.logger.error "AutoBidJob failed due to invalid bid: #{e.message}"
  rescue ActiveRecord::StaleObjectError => e
    Rails.logger.warn "AutoBidJob retry due to stale object: #{e.message}"
    raise e
  rescue StandardError => e
    Rails.logger.error "AutoBidJob unexpected error: #{e.class} - #{e.message}"
    raise e
  end
end
