# frozen_string_literal: true

class AuctionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_auction, only: [:show, :publish]

  def index
    if params[:q].present?
      @auctions = Auction.active.joins(:item).where("items.title LIKE ?", "#{params[:q]}%")
    else
      @auctions = Auction.active
    end
  end

  def manage_auctions
    @draft_auctions = current_user.auctions.draft
    @published_auctions = current_user.auctions.active
  end

  def new
    @auction = Auction.new
  end

  def show
  end

  def drafts
    @drafts = current_user.auctions.where(status: :draft)
  end

  def publish
    if @auction.seller == current_user
      if @auction.start_auction!
        redirect_to auctions_path, notice: "Auction published successfully."
      else
        redirect_to auctions_path, alert: "Failed to publish auction."
      end
    else
      redirect_to auctions_path, alert: "Not authorized to publish this auction."
    end
  end

  def create
    item = Item.find_by(title: auction_params[:title])
    unless item
      item = Item.create(
        title: auction_params[:title],
        description: auction_params[:description]
      )
    end
    @auction = current_user.auctions.build(
      auction_params.except(:title, :description).merge(item: item)
    )
    if @auction.save
      redirect_to @auction, notice: "Auction was successfully created." 
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @auction = current_user.auctions.find(params[:id])
    if @auction.update(auction_params)
      render json: @auction
    else
      render json: { errors: @auction.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def auction_params
    params.require(:auction).permit(:title, :description, :starting_price,
                                    :min_selling_price, :start_time, :end_time)
  end

  def set_auction
    @auction = Auction.find_by(id: params[:id])
  end
end
