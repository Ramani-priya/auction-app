# frozen_string_literal: true

class AuctionNotifierJob
  include Sidekiq::Job

  def perform(auction_id, user_id)
    auction = Auction.find(auction_id)
    user = User.find(user_id)

    Rails.logger.debug { "Auction #{auction.title} won by #{user.email}" }
  end
end
