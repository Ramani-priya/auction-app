require 'rails_helper'

RSpec.describe "bids/_bid_card.html.haml", type: :view do
  let(:auction) { create(:auction) }
  let(:bid) { create(:bid, auction: auction, current_bid_price: 150, created_at: Time.current) }

  it "renders the auction title link" do
    render partial: "bids/bid_card", locals: { bid: bid }
    expect(rendered).to include(auction.title)
  end

  it "renders the bid price" do
    render partial: "bids/bid_card", locals: { bid: bid }
    expect(rendered).to include("Your Bid: $150.0")
  end

  it "renders the bid description with date" do
    render partial: "bids/bid_card", locals: { bid: bid }
    formatted_date = bid.created_at.strftime('%b %d, %Y at %I:%M %p')
    expect(rendered).to include("Placed on #{formatted_date}")
  end

  it "renders the auction link button" do
    render partial: "bids/bid_card", locals: { bid: bid }
    expect(rendered).to include("View Auction")
  end
end
