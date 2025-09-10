require 'rails_helper'

RSpec.describe "bids/new.html.haml", type: :view do
  let(:auction) { create(:auction, starting_price: 50) }
  let(:bid) { build(:bid, auction: auction) }

  before do
    assign(:auction, auction)
    assign(:bid, bid)
  end

  it "renders the new bid page with auction price and form" do
    render
    expect(rendered).to include("Place a Bid")
    expect(rendered).to include("Current bid value:")
    expect(rendered).to include("Back to Auctions")
    expect(rendered).to include("← Back")
  end
end
