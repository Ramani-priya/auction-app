# frozen_string_literal: true

class CreateBidService
  def initialize(auction, bid_params, user)
    @auction = auction
    @bid_params = bid_params
    @user = user
  end

  def call
    @bid = @auction.bids.build(@bid_params.merge(user: @user))

    unless @auction.in_progress?
      @bid.errors.add(:base, 'Auction is not active')
      return @bid
    end

    ActiveRecord::Base.transaction do
      @bid.save
    end
    @bid
  end
end
