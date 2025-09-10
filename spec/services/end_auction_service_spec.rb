# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EndAuctionService, type: :service do
  let(:auction) { create(:auction, status: :active, end_time: Time.current - 1.hour) }
  subject(:service) { described_class.new(auction) }

  describe '#call' do
    context 'when auction is active and end_time is in the past' do
      it 'ends the auction successfully' do
        expect {
          service.call
        }.to change { auction.reload.status }.from('active').to('ended').or change { auction.reload.status }.from('active').to('sold')
      end

      it 'returns true' do
        expect(service.call).to be true
      end
    end

    context 'when auction is inactive' do
      before { auction.update!(status: :ended) }

      it 'does not change the auction status' do
        expect {
          service.call
        }.not_to change { auction.reload.status }
      end

      it 'returns nil or false' do
        expect(service.call).to be_nil.or be false
      end
    end

    context 'when end_time is in the future' do
      before { auction.update!(end_time: Time.current + 1.hour) }

      it 'does not change the auction status' do
        expect {
          service.call
        }.not_to change { auction.reload.status }
      end
    end

    context 'when an exception is raised during end_auction!' do
      before do
        allow(auction).to receive(:end_auction!).and_raise(StandardError.new("Something went wrong"))
      end

      it 'logs the error and does not crash' do
        expect(Rails.logger).to receive(:error).with(/Failed to end auction #{auction.id}: Something went wrong/)
        expect(service.call).to be false
      end
    end
  end
end
