# frozen_string_literal: true

class CreateAuctionService
  def initialize(auction_params, user)
    @auction_params = auction_params
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      item = Item.find_or_create_by!(title: @auction_params[:title])
      @auction = @user.auctions.build(
        @auction_params.except(:title).merge(item: item),
      )
      @auction.save!
    end
    @auction
  end
end
