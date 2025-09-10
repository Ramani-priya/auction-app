# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateAuctionService, type: :service do
  let(:user) { create(:user) }
  let(:auction_params) do
    {
      title: "Unique Item",
      description: "Item description",
      starting_price: 100,
      end_time: 10.days.from_now,
      min_selling_price: 200,
      start_time: 1.day.from_now
    }
  end

  subject(:service) { described_class.new(auction_params, user) }

  describe "#call" do
    context "when item does not exist" do
      it "creates a new item and auction" do
        expect {
          service.call
        }.to change(Item, :count).by(1)
          .and change(Auction, :count).by(1)

        auction = service.call
        expect(auction).to be_persisted
        expect(auction.item.title).to eq("Unique Item")
        expect(auction.seller).to eq(user)
      end
    end

    context "when item already exists" do
      let!(:existing_item) { create(:item, title: "Unique Item") }

      it "does not create a new item but creates an auction" do
        auction = service.call
        expect(auction.item).to eq(existing_item)
      end
    end

    context "when auction params are invalid" do
      before { auction_params[:starting_price] = -10 }

      it "raises an error and does not create an auction" do
        expect {
          service.call
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(Auction.count).to eq(0)
      end
    end

    context "when item creation fails due to validation errors" do
      before do
        allow(Item).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordInvalid.new(Item.new))
      end

      it "raises an error and rolls back transaction" do
        expect {
          service.call
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(Auction.count).to eq(0)
      end
    end

    context "when multiple requests try to create the same item" do
      it "ensures only one item is created" do
        expect {
          threads = []
          2.times do
            threads << Thread.new { described_class.new(auction_params, user).call rescue nil }
          end
          threads.each(&:join)
        }.to change(Item, :count).by(1)
      end
    end
  end
end
