# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuctionResult do
  describe 'associations' do
    it { is_expected.to belong_to(:auction) }
    it { is_expected.to belong_to(:winning_bid).class_name('Bid') }
    it { is_expected.to belong_to(:winner).class_name('User') }
  end

  describe 'valid factory' do
    let(:auction_result) { create(:auction_result) }

    it 'is valid with valid attributes' do
      expect(auction_result).to be_valid
    end
  end
end
