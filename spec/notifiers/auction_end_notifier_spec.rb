
require 'rails_helper'
RSpec.describe AuctionEndNotifier, type: :model do
  let(:auction) { create(:auction, end_time: 1.hour.ago, status: "ended") }
  let(:mailer) { double('AuctionEndedMailer') }
  let(:seller_email) { double('Mailer') }

  describe '.notify' do
    it 'sends an email to the seller' do
      allow(AuctionEndedMailer).to receive(:with).with(auction: auction, seller: auction.seller).and_return(mailer)
      allow(mailer).to receive(:seller_email).and_return(seller_email)
      allow(seller_email).to receive(:deliver_later)
      described_class.notify(auction)
      expect(AuctionEndedMailer).to have_received(:with) do |args|
        expect(args[:auction].id).to eq(auction.id)
        expect(args[:seller].id).to eq(auction.seller.id)
      end
      expect(mailer).to have_received(:seller_email)
      expect(seller_email).to have_received(:deliver_later)
    end
  end
end
