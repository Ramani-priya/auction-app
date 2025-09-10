require 'rails_helper'

RSpec.describe "auctions/edit.html.haml", type: :view do
  let(:auction) { create(:auction) }

  before do
    assign(:auction, auction)
  end

  it "renders the form and back link" do
    render
    expect(rendered).to include("Edit Auction")
    expect(rendered).to include("← Back")
  end
end
