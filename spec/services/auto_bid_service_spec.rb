require 'rails_helper'

RSpec.describe AutoBidService, type: :service do
  describe "#call" do
    let!(:seller) { create(:user) }
    let!(:auction) { create(:auction, status: :active, seller: seller) }
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }

    context "basic scenarios" do
      it "does nothing if the triggering bid is system-generated" do
        create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 100, system_generated: true)
        service = AutoBidService.new(auction.id)
        expect(service.call).to be_nil
      end

      it "does nothing if there are no eligible autobidders" do
        create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 100, system_generated: false)
        service = AutoBidService.new(auction.id)
        expect(service.call).to be_nil
      end
    end

    context "single autobidder scenario" do
      let(:auction) { create(:auction) }
      
      before do
        create(:bid, auction: auction, user: user2, current_bid_price: 55, max_bid_price: 120, autobid: true, system_generated: false)
        create(:bid, auction: auction, user: user1, current_bid_price: 60, system_generated: false)
      end

      it "creates a valid auto-bid with current bid price + min increment when the triggering bid is a manual bid" do
        service = AutoBidService.new(auction.id)
        bid = service.call

        expect(bid).to be_persisted
        expect(bid.user).to eq(user2)
        expect(bid.current_bid_price).to eq(61)
      end
    end

    context "multiple autobidders scenarios" do
      it "handles different max prices" do
        create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 100, system_generated: false)
        create(:bid, auction: auction, user: user2, current_bid_price: 60, max_bid_price: 160, autobid: true, system_generated: false)
        create(:bid, auction: auction, user: user3, current_bid_price: 70, max_bid_price: 170, autobid: true, system_generated: false)
        service = AutoBidService.new(auction.id)
        bid = service.call

        expect(bid.user).to eq(user3)
        expect(bid.current_bid_price).to eq(161)
      end

      it "resolves tie by creation time when max prices are equal" do
        create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 100, system_generated: false)
        create(:bid, auction: auction, user: user2, current_bid_price: 60, max_bid_price: 100, autobid: true, system_generated: false, created_at: 2.hours.ago)
        create(:bid, auction: auction, user: user3, current_bid_price: 70, max_bid_price: 100, autobid: true, system_generated: false, created_at: 1.hour.ago)

        service = AutoBidService.new(auction.id)
        bid = service.call

        expect(bid.user).to eq(user2)
        expect(bid.current_bid_price).to eq(71) # pays 1 more than triggering bid since there is no second highest
      end
    end

    it "takes second highest's max price plus increment if available" do
      create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 100, system_generated: false)
      create(:bid, auction: auction, user: user2, current_bid_price: 60, max_bid_price: 130, autobid: true, system_generated: false)
      create(:bid, auction: auction, user: user3, current_bid_price: 70, max_bid_price: 120, autobid: true, system_generated: false)

      service = AutoBidService.new(auction.id)
      bid = service.call

      expect(bid.current_bid_price).to eq(121)
    end

    it "falls back to triggering bid price when second highest is not available and no other auto bids" do
      create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 100, system_generated: false)
      create(:bid, auction: auction, user: user2, current_bid_price: 60, max_bid_price: 120, autobid: true, system_generated: false)

      service = AutoBidService.new(auction.id)
      bid = service.call
      expect(bid).to be_nil
      expect(auction.reload.current_highest_bid).to eq(user2.bids.last)
    end

    it "falls back to triggering bid price when second highest is not available and no other auto bids with max bid price > current bid price" do
      create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 60, autobid: true, system_generated: false)
      create(:bid, auction: auction, user: user2, current_bid_price: 70, max_bid_price: 120, autobid: true, system_generated: false)

      service = AutoBidService.new(auction.id)
      bid = service.call

      expect(bid).to be_nil
      expect(auction.reload.current_highest_bid).to eq(user2.bids.last)
    end

    context "edge case: same max bid, min increment exceeds cap" do
      it "chooses the earliest created autobid and caps price at max_bid_price" do
        create(:bid, auction: auction, user: user1, current_bid_price: 50, max_bid_price: 70, system_generated: false)
        create(:bid, auction: auction, user: user2, current_bid_price: 80, max_bid_price: 100,
              autobid: true, system_generated: false, created_at: 2.hours.ago)
        create(:bid, auction: auction, user: user3, current_bid_price: 99, max_bid_price: 100,
              autobid: true, system_generated: false, created_at: 1.hour.ago)

        service = AutoBidService.new(auction.id)
        bid = service.call

        expect(bid.user).to eq(user2)
        expect(bid.current_bid_price).to eq(100)
      end
    end

    context "error handling" do
      it "raises RecordNotFound if auction does not exist" do
        service = AutoBidService.new(0)
        expect { service.call }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises AuctionInactiveError if auction is not active" do
        auction.end_auction!
        service = AutoBidService.new(auction.id)
        expect { service.call }.to raise_error(AuctionErrors::AuctionInactiveError)
      end
    end
  end
end
