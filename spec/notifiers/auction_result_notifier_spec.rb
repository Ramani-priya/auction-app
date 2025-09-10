require 'rails_helper'

RSpec.describe AuctionResultNotifier, type: :model do
  let(:user) { create(:user) }
  let(:seller) { create(:user) }
  let(:bid) { create(:bid, user: user, current_bid_price: 100) }
  let(:auction) { create(:auction, seller: seller, current_highest_bid: bid, end_time: 1.hour.ago) }
  let(:mailer) { double('AuctionResultMailer') }

  before do
    stub_const("AuctionResultNotifier::WEBHOOK_CONFIG", { auction_result_url: "https://example.com", auction_result_token: "secret" })
  end

  describe '.notify' do
    it 'sends the webhook and emails' do
      allow(WebhookClient).to receive(:send)
      allow(AuctionResultMailer).to receive(:with).and_return(mailer)
      allow(mailer).to receive(:winner_email).and_return(mailer)
      allow(mailer).to receive(:seller_email).and_return(mailer)
      allow(mailer).to receive(:deliver_later)

      described_class.notify(auction)

      expect(WebhookClient).to have_received(:send).with("https://example.com", anything, hash_including("Authorization" => "Bearer secret"))
      expect(AuctionResultMailer).to have_received(:with).with(auction: auction, winner: user, seller: seller).twice
      expect(mailer).to have_received(:deliver_later).at_least(:once)
    end

    it 'does nothing if there is no current_highest_bid' do
      auction.update(current_highest_bid: nil)
      expect(WebhookClient).not_to receive(:send)
      expect(AuctionResultMailer).not_to receive(:with)

      described_class.notify(auction)
    end

    it 'rescues errors and logs them' do
      allow(WebhookClient).to receive(:send).and_raise(StandardError.new("Webhook failed"))
      expect(Rails.logger).to receive(:error).with(/Failed to notify external system: StandardError - Webhook failed/)

      described_class.notify(auction)
    end
  end
end

