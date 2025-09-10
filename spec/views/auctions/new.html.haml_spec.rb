# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'auctions/new.html.haml', type: :view do
  let(:auction) { build(:auction) }

  before do
    assign(:auction, auction)
  end

  it 'renders the form and back link' do
    render
    expect(rendered).to include('New Auction')
    expect(rendered).to include('← Back')
  end
end
