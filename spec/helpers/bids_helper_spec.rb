# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BidsHelper, type: :helper do
  let(:auction) { create(:auction, starting_price: 100, min_selling_price: 200) }
  let(:bid) { create(:bid, auction: auction, current_bid_price: 150) }

  describe "#bid_price" do
    it "returns the formatted bid price" do
      expect(helper.bid_price(bid)).to eq("Your Bid: $150.00")
    end
  end

  describe "#bid_description" do
    it "returns the formatted created_at date" do
      formatted_date = bid.created_at.strftime('%b %d, %Y at %I:%M %p')
      expect(helper.bid_description(bid)).to eq("Placed on #{formatted_date}")
    end
  end

  describe "#current_bid_value" do
    context "when auction has a highest bid" do
      it "returns the current highest bid price" do
        create(:bid, auction: auction, current_bid_price: 200)
        expect(helper.current_bid_value(auction)).to eq(200)
      end
    end

    context "when auction has no bids" do
      it "returns the starting price" do
        expect(helper.current_bid_value(auction)).to eq(100)
      end
    end
  end
end
