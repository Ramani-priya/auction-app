# frozen_string_literal: true

require "rails_helper"

RSpec.describe BidsController, type: :routing do
  it "routes GET /auctions/:auction_id/bids/new to bids#new" do
    expect(get: "/auctions/1/bids/new").to route_to("bids#new", auction_id: "1")
  end

  it "routes POST /auctions/:auction_id/bids to bids#create" do
    expect(post: "/auctions/1/bids").to route_to("bids#create", auction_id: "1")
  end

  it "routes GET /bids to bids#index" do
    expect(get: "/bids").to route_to("bids#index")
  end
end
