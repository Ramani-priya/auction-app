# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhookClient do
  let(:url) { 'https://external-system.com/api/notify' }
  let(:token) { 'secret-token' }
  let(:payload) do
    { auction_id: 1, winner_id: 2, final_price: 100, ended_at: Time.current }
  end
  let(:headers) do
    { 'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token}" }
  end

  describe '.post' do
    it 'sends a POST request to the correct URL with payload and token' do
      stub_request(:post, url).to_return(status: 200, body: '', headers: {})

      expect do
        described_class.send(url, payload.to_json, headers)
      end.not_to raise_error
    end

    it 'raises an error if request fails' do
      stub_request(:post, url).to_return(status: 500)
      expect do
        described_class.post(url, payload.to_json,
                             headers)
      end.to raise_error(StandardError)
    end
  end
end
