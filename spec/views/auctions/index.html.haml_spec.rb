# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'auctions/index.html.haml', type: :view do
  before do
    20.times { create(:auction) }
    assign(:auctions, Kaminari.paginate_array(Auction.all).page(1).per(10))
  end

  it 'renders the auctions and search bar' do
    render
    expect(rendered).to include('Auctions')
    expect(rendered).to include('Search auctions...')
    expect(rendered).to include(Auction.first.title)
  end
end
