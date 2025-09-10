# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuctionsHelper, type: :helper do
  let(:user) { create(:user) }
  let(:auction) do
    create(:auction, starting_price: 100, min_selling_price: 200)
  end

  describe '#auction_current_price' do
    it 'shows starting price when there is no highest bid' do
      expect(helper.auction_current_price(auction)).to eq('$100.00')
    end

    it 'shows current highest bid price if present' do
      bid = create(:bid, auction: auction, current_bid_price: 150)
      auction.current_highest_bid = bid
      expect(helper.auction_current_price(auction)).to eq('$150.00')
    end
  end

  describe '#auction_price' do
    it 'returns nil if show_price is false' do
      expect(helper.auction_price(auction, false)).to be_nil
    end

    it 'returns a price tag if show_price is true' do
      result = helper.auction_price(auction, true)
      expect(result).to include('Current Price:')
    end
  end

  describe '#auction_description' do
    it 'returns nil if show_description is false' do
      expect(helper.auction_description(auction, false)).to be_nil
    end

    it 'returns a description paragraph if show_description is true' do
      result = helper.auction_description(auction, true)
      expect(result).to include(auction.description)
    end
  end

  describe '#auction_details_link' do
    it 'returns nil if show_details is false' do
      expect(helper.auction_details_link(auction, false)).to be_nil
    end

    it 'returns a link if show_details is true' do
      result = helper.auction_details_link(auction, true)
      expect(result).to include('View Details')
    end
  end

  describe '#auction_publish_button' do
    it 'returns nil if show_publish is false' do
      expect(helper.auction_publish_button(auction, false)).to be_nil
    end

    it 'returns a button if show_publish is true' do
      result = helper.auction_publish_button(auction, true)
      expect(result).to include('Publish')
    end
  end
end
