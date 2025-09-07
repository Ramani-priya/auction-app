# frozen_string_literal: true

class EndAuctionsJob
  include Sidekiq::Job

  def perform
    ActiveRecord::Base.transaction do
      Auction.active
             .where(ends_at: ..Time.current)
             .find_each(batch_size: 500, &:end_auction!)
    end
  rescue StandardError => e
    Rails.logger.error("Failed to end auction #{auction.id}: #{e.message}")
    # Optionally: notify via error tracking (e.g., Sentry, Rollbar)
  end
end
