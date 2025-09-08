class CreateBidService
  def initialize(auction, bid_params, user)
    @auction = auction
    @bid_params = bid_params
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      @bid = @auction.bids.build(@bid_params.merge(user: @user))
      @bid.save
    end
    @bid
  end
end