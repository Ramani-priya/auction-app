# frozen_string_literal: true

require "rails_helper"

RSpec.describe BidProcessingService, type: :service do
  let!(:seller) { create(:user) }
  let!(:bidder) { create(:user) }
  let!(:auction) { create(:auction, seller: seller) }
  let!(:old_bid) { create(:bid, auction: auction, user: bidder, status: :active) }
  let!(:bid) do
    create(
      :bid,
      auction: auction,
      user: bidder,
      current_bid_price: auction.current_highest_bid.current_bid_price + 10
    )
  end

  subject(:service) { described_class.new(bid) }

  describe "#call" do
    context "when processing a valid bid" do
      it "updates the auction's current_highest_bid_id" do
        service.call
        expect(auction.reload.current_highest_bid_id).to eq(bid.id)
      end

      it "outdates previous bids from the same user" do
        old_bid.update_column(:status, "active")
        service.call
        expect(old_bid.reload.status).to eq("outdated")
      end
    end
  end
end