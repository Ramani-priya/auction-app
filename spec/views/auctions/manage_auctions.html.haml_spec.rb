# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'auctions/manage_auctions.html.haml', type: :view do
  let(:draft_auction) { create(:auction) }
  let(:published_auction) { create(:auction) }

  before do
    assign(:draft_auctions, [draft_auction])
    assign(:published_auctions, [published_auction])
  end

  it 'renders the draft and published auctions' do
    render
    expect(rendered).to include('Draft Auctions')
    expect(rendered).to include('Published Auctions')
    expect(rendered).to include('Create New Auction')
  end
end
