# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuctionsController, type: :routing do
  it "routes GET /auctions to auctions#index" do
    expect(get: "/auctions").to route_to("auctions#index")
  end

  it "routes GET /auctions/new to auctions#new" do
    expect(get: "/auctions/new").to route_to("auctions#new")
  end

  it "routes POST /auctions to auctions#create" do
    expect(post: "/auctions").to route_to("auctions#create")
  end

  it "routes GET /auctions/:id to auctions#show" do
    expect(get: "/auctions/1").to route_to("auctions#show", id: "1")
  end

  it "routes GET /auctions/:id/publish to auctions#publish" do
    expect(patch: "/auctions/1/publish").to route_to("auctions#publish", id: "1")
  end
end