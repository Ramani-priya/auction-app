# frozen_string_literal: true

class AutoBidService
  def initialize(auction_id)
    @auction_id = auction_id
  end

  def call
    ActiveRecord::Base.transaction do
      auction = Auction.find_by(id: @auction_id)
      raise ActiveRecord::RecordNotFound, 'Auction not found' unless auction

      unless auction.active?
        raise AuctionErrors::AuctionInactiveError,
              'Auction is not active'
      end

      triggering_bid = auction.current_highest_bid
      return if triggering_bid.blank? || triggering_bid.system_generated?

      triggering_bidder = triggering_bid.user
      current_price = triggering_bid.current_bid_price

      eligible_autobids = auction.bids.active.autobid
                                 .where('max_bid_price > ?', current_price)
                                 .order(max_bid_price: :desc, created_at: :asc)

      autobids_from_other_users = eligible_autobids.where.not(user_id: triggering_bidder.id)
      return if autobids_from_other_users.empty?

      highest_autobid = eligible_autobids.first
      second_highest_autobid = eligible_autobids
                               .where.not(max_bid_price: highest_autobid.max_bid_price)
                               .first

      final_price = determine_final_price(current_price, auction.minimum_increment,
                                          highest_autobid, second_highest_autobid)

      bid = build_new_bid(auction, highest_autobid.user, final_price)

      unless bid.save
        raise AuctionErrors::AuctionBidCreationError,
              "Failed to create bid: #{bid.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def determine_final_price(current_price, min_increment, highest_autobid,
                            second_highest_autobid)
    if second_highest_autobid
      [second_highest_autobid.max_bid_price + min_increment,
       highest_autobid.max_bid_price].min
    else
      [(current_price + min_increment), highest_autobid.max_bid_price].min
    end
  end

  def build_new_bid(auction, user, price)
    Bid.new(
      auction: auction,
      user: user,
      current_bid_price: price,
      status: :active,
      autobid: true,
      max_bid_price: price,
      system_generated: true,
    )
  end
end
