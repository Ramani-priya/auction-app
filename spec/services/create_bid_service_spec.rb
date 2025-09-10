# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateBidService, type: :service do
  let(:user) { create(:user) }
  let(:auction) { create(:auction, status: :active) }
  let(:bid_params) do
    {
      current_bid_price: 100,
      max_bid_price: 150,
      autobid: false
    }
  end

  subject(:service) { described_class.new(auction, bid_params, user) }

  describe '#call' do
    context 'when auction is active and bid params are valid' do
      it 'creates a new bid' do
        bid = service.call
        expect(bid).to be_persisted
        expect(bid.user).to eq(user)
        expect(bid.auction).to eq(auction)
        expect(bid.current_bid_price).to eq(100)
        expect(bid.max_bid_price).to eq(150)
        expect(bid.autobid).to be false
      end
    end

    context 'when bid params are invalid' do
      before { bid_params[:current_bid_price] = -10 }
      subject(:service) { described_class.new(auction, bid_params, user) }

      it 'does not save bid' do
        bid = service.call
        expect(bid.new_record?).to eq(true)
      end
    end
  end
end
