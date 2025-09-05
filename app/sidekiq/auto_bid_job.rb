class AutoBidJob
  include Sidekiq::Job

  def perform(auction_id, user_id, max_bid)
    auction = Auction.find(auction_id)
    user    = User.find(user_id)

    return if auction.ended?

    current_highest_bid = auction.bids.maximum(:amount) || auction.starting_price
    next_bid = current_highest_bid + auction.min_increment

    if next_bid <= max_bid
      auction.bids.create!(user:, amount: next_bid)
      # Re-enqueue until max_bid is reached or auction ends
      AutoBidJob.perform_in(30.seconds, auction.id, user.id, max_bid)
    else
      Rails.logger.info "User #{user.id} reached max bid for Auction #{auction.id}"
    end
  end
end
