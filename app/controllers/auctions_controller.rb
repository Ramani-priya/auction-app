# frozen_string_literal: true

class AuctionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_auction, only: %i[show publish]
  before_action :authorize_seller, only: [:publish]

  def index
    if params[:q].present?
      @auctions = Auction.active.joins(:item).where('items.title LIKE ?',
                                                    "#{params[:q]}%")
    else
      @auctions = Auction.active
    end
    @auctions = @auctions.includes(:item, :current_highest_bid)
                         .page(params[:page])
                         .per(10)
  end

  def manage_auctions
    @draft_auctions = current_user.auctions.draft.includes(:item,
                                                           :current_highest_bid)
    @published_auctions = current_user.auctions.published.includes(:item,
                                                                   :current_highest_bid)
  end

  def show; end

  def new
    @auction = Auction.new
  end

  def publish
    if @auction.start_auction!
      redirect_to auctions_path, notice: 'Auction published successfully.'
    else
      redirect_to auctions_path, alert: 'Failed to publish auction.'
    end
  end

  def create
    @auction = CreateAuctionService.new(auction_params, current_user).call
    if @auction.persisted?
      redirect_to manage_auctions_auctions_path, notice: 'Auction was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def auction_params
    params.require(:auction).permit(:title, :description, :starting_price,
                                    :min_selling_price, :start_time, :end_time)
  end

  def set_auction
    @auction = Auction.find_by(id: params[:id])
    return if @auction

    redirect_to auctions_path, alert: 'Auction does not exist'
  end

  def authorize_seller
    return if @auction.seller == current_user

    redirect_to auctions_path,
                alert: 'Not authorized to publish this auction.'
  end
end
