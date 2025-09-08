# frozen_string_literal: true

class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_auction, only: %i[new create]

  def index
    @user_bids = current_user.bids.includes({ auction: :item }).order(created_at: :desc)
  end

  def new
    @bid = @auction.bids.build
  end

  def create
    @bid = CreateBidService.new(@auction, bid_params, current_user).call
    if @bid.persisted?
      redirect_to @auction, notice: 'Bid placed successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_auction
    @auction = Auction.find(params[:auction_id])
  end

  def bid_params
    params.require(:bid).permit(:current_bid_price, :max_bid_price, :autobid)
  end
end
