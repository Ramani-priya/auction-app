# frozen_string_literal: true

class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_auction, only: %i[new create]

  def index
    @user_bids = current_user.bids.includes({ auction: :item })
                             .order(created_at: :desc)
                             .page(params[:page])
                             .per(10)
  end

  def new
    unless @auction.in_progress?
      redirect_to @auction, alert: 'Auction is not active'
    end
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
    @auction = Auction.find_by(id: params[:auction_id])
    return if @auction

    redirect_to auctions_path, alert: 'Auction does not exist'
  end

  def bid_params
    params.require(:bid).permit(:current_bid_price, :max_bid_price, :autobid)
  end
end
