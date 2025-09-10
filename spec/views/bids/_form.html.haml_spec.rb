require 'rails_helper'

RSpec.describe "bids/_form.html.haml", type: :view do
  let(:auction) { create(:auction) }
  let(:bid) { build(:bid, auction: auction) }

  before do
    assign(:auction, auction)
    assign(:bid, bid)
  end

  it "renders the form fields" do
    render
    expect(rendered).to have_field('bid_current_bid_price')
    expect(rendered).to have_field('bid_max_bid_price')
  end
end
