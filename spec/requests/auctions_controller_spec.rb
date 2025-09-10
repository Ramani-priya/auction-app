# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuctionsController, type: :request do
  let(:user) { create(:user) }
  let(:auction) { create(:auction, seller: user) }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      get auctions_path
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get auction_path(auction)
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get new_auction_path
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    it 'creates a new auction' do
      item = create(:item)
      expect do
        post auctions_path,
             params: { auction: attributes_for(:auction, item_id: item.id) }
      end.to change(Auction, :count).by(1)
    end
  end
end
