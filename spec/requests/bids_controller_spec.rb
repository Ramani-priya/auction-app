require 'rails_helper'

RSpec.describe BidsController, type: :request do
  let(:user) { create(:user) }
  let(:auction) { create(:auction) }

  before { sign_in user }

  describe "GET #new" do
    it "returns a success response" do
      get new_auction_bid_path(auction)
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    it "creates a new bid" do
      expect {
        post auction_bids_path(auction), params: { bid: attributes_for(:bid, auction_id: auction.id, user_id: user.id) }
      }.to change(Bid, :count).by(1)
    end

    it "renders new on failure" do
      post auction_bids_path(auction), params: { bid: { current_bid_price: nil } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end