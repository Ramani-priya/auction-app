require 'rails_helper'

RSpec.describe AutoBidTriggerService, type: :service do
  let!(:auction) { create(:auction, status: :active) }
  let!(:user) { create(:user) }

  subject { described_class.new(auction) }

  describe "#call" do
    context "when auction is not active" do
      it "does not enqueue AutoBidJob" do
        auction.update!(status: :ended)
        expect(AutoBidJob).not_to receive(:perform_async)
        subject.call
      end
    end

    context "when the current highest bid is system generated" do
      it "does not enqueue AutoBidJob" do
        create(:bid, auction: auction, user: user, current_bid_price: 50, max_bid_price: 100, system_generated: true)
        expect(AutoBidJob).not_to receive(:perform_async)
        subject.call
      end
    end

    context "when the auction is active and the current highest bid is not system generated" do
      it "enqueues AutoBidJob" do
        create(:bid, auction: auction, user: user, current_bid_price: 50, max_bid_price: 100, system_generated: false)
        expect(AutoBidJob).to receive(:perform_async).with(auction.id)
        subject.call
      end
    end

    context "when there is no current highest bid" do
      it "enqueues AutoBidJob if auction is active" do
        expect(AutoBidJob).to receive(:perform_async).with(auction.id)
        subject.call
      end
    end
  end
end
