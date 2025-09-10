# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'auctions/_auction_card.html.haml', type: :view do
  let(:auction) { create(:auction, starting_price: 50) }

  it 'renders the auction title link' do
    render partial: 'auctions/auction_card',
           locals: { auction: auction, show_price: false, show_description: false,
                     show_details: false, show_publish: false }
    expect(rendered).to include(auction.title)
  end

  it 'shows the price if show_price is true' do
    render partial: 'auctions/auction_card',
           locals: { auction: auction, show_price: true, show_description: false,
                     show_details: false, show_publish: false }
    expect(rendered).to include('Current Price:')
  end

  it 'shows the description if show_description is true' do
    render partial: 'auctions/auction_card',
           locals: { auction: auction, show_price: false, show_description: true,
                     show_details: false, show_publish: false }
    expect(rendered).to include(auction.description)
  end

  it 'renders the details link if show_details is true' do
    render partial: 'auctions/auction_card',
           locals: { auction: auction, show_price: false, show_description: false,
                     show_details: true, show_publish: false }
    expect(rendered).to include('View Details')
  end

  it 'renders the publish button if show_publish is true' do
    render partial: 'auctions/auction_card',
           locals: { auction: auction, show_price: false, show_description: false,
                     show_details: false, show_publish: true }
    expect(rendered).to include('Publish')
  end
end
