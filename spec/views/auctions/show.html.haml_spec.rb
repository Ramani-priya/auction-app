require 'rails_helper'

RSpec.describe "auctions/show.html.haml", type: :view do
  let(:auction) { create(:auction) }
  let(:user) { create(:user) }

  before do
    assign(:auction, auction)
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
  end

  it "renders the auction card and bid link if not the seller" do
    allow(auction).to receive(:seller).and_return(create(:user))
    render
    expect(rendered).to include(auction.title)
    expect(rendered).to include("Place a Bid")
  end
end
