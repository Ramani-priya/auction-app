# frozen_string_literal: true

class AutoBidJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: 3

  def perform(auction_id)
    Rails.logger.info "Running AutoBidJob for auction #{auction_id}"
    binding.pry
    auction = Auction.find_by(id: auction_id)
    return unless auction&.active?
    ActiveRecord::Base.transaction do
      triggering_bid = auction.current_highest_bid
      # if there's no current highest bid or if it's a system-generated bid, do nothing
      return if triggering_bid.blank? || triggering_bid.system_generated?
      triggering_bidder = triggering_bid.user
      current_price = triggering_bid.current_bid_price
      # Find the next eligible auto-bidder
      eligible_autobids = auction.bids.active.autobid
                            .where('max_bid_price > ?', current_price)
                            .order(max_bid_price: :desc, created_at: :asc)
      autobids_from_other_users = eligible_autobids.where.not(user_id: triggering_bidder.id)
      return if autobids_from_other_users.empty?
      current_eligible_autobid = eligible_autobids.first # this can be triggering_bidder too
      second_highest = eligible_autobids
                      .where.not(max_bid_price: current_eligible_autobid.max_bid_price)
                      .first
      # Determine the new bid price just above the second highest or triggering bid so that it is the smallest possible incremented value
      final_price = if second_highest
        [second_highest.max_bid_price + auction.minimum_increment, current_eligible_autobid.max_bid_price].min
      else
        [triggering_bid&.current_bid_price + auction.minimum_increment, current_eligible_autobid.max_bid_price].min
      end
      # Create a new bid for the eligible auto-bidder with the smallest possible incremented value
      bid = Bid.new(
        auction_id: auction.id,
        user_id: current_eligible_autobid.user_id,
        autobid: true,
        max_bid_price: current_eligible_autobid.max_bid_price,
        current_bid_price: final_price,
        system_generated: true,
      )
      if bid.save
        binding.pry
        # outdate the previous auto-bid
        current_eligible_autobid.outdate!
      else
        Rails.logger.error "AutoBidJob failed to create bid for auction #{auction.id} by user #{current_eligible_autobid.user_id}"
        Rails.logger.error "Errors: #{bid.errors.full_messages.join(', ')}"
      end
    end
  rescue StandardError => e
    Rails.logger.error "AutoBidJob unexpected error: #{e.class} - #{e.message}"
    raise e # Sidekiq retries
  end
end
