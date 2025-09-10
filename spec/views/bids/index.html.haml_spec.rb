require 'rails_helper'

RSpec.describe "bids/index.html.haml", type: :view do
  let(:auction) { create(:auction, starting_price: 50, min_selling_price: 100) }
  let(:bid) { create(:bid, auction: auction, current_bid_price: 120) }

  before do
    20.times do |i| create(:bid, auction: auction, current_bid_price: 180+i) end
    assign(:user_bids, Kaminari.paginate_array(auction.bids.reload).page(1).per(10))
  end

  it "renders the bid cards and back link" do
    render
    expect(rendered).to include("Your Bid:")
    expect(rendered).to include("← Back")
  end
end
