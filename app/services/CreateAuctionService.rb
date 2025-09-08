# frozen_string_literal: true

class CreateAuctionService
  def initialize(auction_params, user)
    @auction_params = auction_params
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      item = Item.find_by(title: @auction_params[:title])
      item ||= Item.create!(
        title: @auction_params[:title],
        description: @auction_params[:description],
      )
      @auction = @user.auctions.build(
        @auction_params.except(:title, :description).merge(item: item),
      )
      @auction.save
    end
    @auction
  end
end
