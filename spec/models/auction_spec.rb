# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auction do
  describe 'associations' do
    let(:seller) { create(:user) }
    let(:item) { create(:item) }

    subject do
      Auction.new(
        starting_price: 10,
        min_selling_price: 20,
        start_time: 1.hour.ago,
        end_time: 1.hour.from_now,
        seller: seller,
        item: item
      )
    end

    it { is_expected.to belong_to(:item).optional }
    it { is_expected.to belong_to(:seller).class_name('User') }
    it { is_expected.to have_many(:bids) }

    it { expect(subject).to have_one(:auction_result) }
  end

  describe 'validations' do
    let(:seller) { create(:user) }
    let(:item) { create(:item) }

    it { is_expected.to validate_presence_of(:starting_price) }
    it { is_expected.to validate_presence_of(:min_selling_price) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_numericality_of(:starting_price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:min_selling_price).is_greater_than_or_equal_to(0) }

    it 'validates end_time > start_time' do
      auction = build(
        :auction,
        starting_price: 10,
        min_selling_price: 20,
        start_time: 1.hour.ago,
        end_time: 2.hours.ago,
        seller: seller,
        item: item
      )
      expect(auction).not_to be_valid
      expect(auction.errors[:end_time]).to include("must be greater than #{auction.start_time}")
    end
  end

  describe 'aasm transitions' do
    it 'transitions from draft → active' do
      auction = build(:auction, status: :draft)
      auction.start_auction!  # trigger the event
      expect(auction).to be_active
    end

    it 'transitions active → ended if no winner' do
      allow(AuctionEndNotifier).to receive(:notify)
      auction = build(:auction, status: :active)
      allow(auction).to receive(:no_winner?).and_return(true)
      auction.end_auction!
      expect(auction).to be_ended
      expect(AuctionEndNotifier).to have_received(:notify).with(auction)
    end

    it 'transitions active → sold if has winner' do
      auction = build(:auction, status: :active)
      allow(auction).to receive(:has_winner?).and_return(true)
      auction.end_auction!
      expect(auction).to be_sold
    end
  end


  describe '.pending_to_end' do
    it 'returns active auctions that have passed end_time' do
      past_auction = create(:auction, status: :active, end_time: 1.minute.ago)
      future_auction = create(:auction, status: :active, end_time: 1.hour.from_now)
      expect(Auction.pending_to_end).to include(past_auction)
      expect(Auction.pending_to_end).not_to include(future_auction)
    end
  end

  describe '#sold_auction_callback' do
    let(:seller) { create(:user) }
    let(:item) { create(:item) }
    let(:auction) do
      build(
        :auction,
        starting_price: 10,
        min_selling_price: min_selling_price,
        start_time: 1.hour.ago,
        end_time: 1.hour.from_now,
        seller: seller,
        item: item
      )
    end
    let(:winning_user) { create(:user) }
    let(:winning_bid) do
      create(:bid, auction: auction, user: winning_user, current_bid_price: 25)
    end

    before { auction.current_highest_bid = winning_bid }

    context 'when price >= min_selling_price' do
      let(:min_selling_price) { 20 }

      it 'creates auction_result' do
        expect { auction.send(:sold_auction_callback) }
          .to change(AuctionResult, :count).by(1)
      end
    end

    context 'when price < min_selling_price' do
      let(:min_selling_price) { 30 }

      it 'does not create auction_result' do
        expect { auction.send(:sold_auction_callback) }
          .not_to change(AuctionResult, :count)
      end
    end
  end

  describe '#minimum_increment' do
    let(:auction) { build(:auction) }

    {
      0.5 => 0.05,
      3.0 => 0.25,
      10.0 => 0.50,
      50.0 => 1,
      150.0 => 2,
      300.0 => 5,
      1000.0 => 10,
    }.each do |price, expected_increment|
      it "returns #{expected_increment} for price #{price}" do
        auction.current_highest_bid = build(:bid, current_bid_price: price)
        expect(auction.minimum_increment).to eq(expected_increment)
      end
    end
  end
end
