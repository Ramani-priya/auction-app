# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe Bid do
  let(:user)    { create(:user) }
  let(:auction) { create(:auction, status: :active) }

  describe 'associations' do
    it { is_expected.to belong_to(:auction) }
    it { is_expected.to belong_to(:user) }

    it {
      expect(subject).to have_one(:auction_result).with_foreign_key(:winning_bid_id)
    }
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:status).with_values(outdated: 0, active: 1, winning: 2)
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:current_bid_price) }

    it {
      expect(subject).to validate_numericality_of(:current_bid_price).is_greater_than_or_equal_to(0)
    }

    context 'when autobid is true' do
      subject do
        build(
          :bid,
          auction: auction,
          user: user,
          autobid: true,
          current_bid_price: 100,
          max_bid_price: nil
        )
      end

      it 'requires max_bid_price' do
        expect(subject).not_to be_valid
        expect(subject.errors[:max_bid_price]).to include("can't be blank")
      end
    end

    context 'custom validation: price_is_higher_than_current_highest_bid' do
      let!(:highest_bid) do
        create(:bid, auction: auction, user: user, current_bid_price: 200)
      end
      let(:new_bid) do
        build(:bid, auction: auction, user: create(:user), current_bid_price: 150)
      end

      it 'is invalid if not higher than current highest bid' do
        expect(new_bid).not_to be_valid
        expect(new_bid.errors[:current_bid_price]).to include('must be higher than the current highest bid')
      end
    end

    context 'custom validation: max_bid_is_higher_than_current_bid_price' do
      let(:bid) do
        build(:bid, auction: auction, user: user, current_bid_price: 200, max_bid_price: 150, autobid: true)
      end

      it 'is invalid if max_bid_price < current_bid_price' do
        expect(bid).not_to be_valid
        expect(bid.errors[:max_bid_price]).to include('cannot be less than the current bid price')
      end
    end
  end

  describe 'AASM state machine' do
    let(:bid) { create(:bid, auction: auction, user: user, status: :active) }

    it 'starts as active' do
      expect(bid).to be_active
    end

    it 'can transition to outdated' do
      bid.outdate!
      expect(bid).to be_outdated
    end
  end

  describe 'callbacks' do
    context 'after create' do
      let!(:highest_bid) do
        create(:bid, auction: auction, user: user, current_bid_price: 200, max_bid_price: 300)
      end
      let(:new_bid) do
        build(:bid, auction: auction, user: user, current_bid_price: 300, max_bid_price: 300)
      end

      it 'updates auction.current_highest_bid' do
        new_bid.save!
        expect(auction.reload.current_highest_bid).to eq(new_bid)
      end

      it 'outdates the previous highest bid' do
        new_bid.save!
        expect(highest_bid.reload).to be_outdated
      end

      it 'enqueues AutoBidJob unless system_generated' do
        Sidekiq::Worker.clear_all
        expect {
          new_bid.save!  # triggers callback
        }.to change(AutoBidJob.jobs, :size).by(1)

        job = AutoBidJob.jobs.last
        expect(job['args']).to eq([new_bid.auction.id])
      end

      it 'does not enqueue AutoBidJob if system_generated' do
        ActiveJob::Base.queue_adapter = :test
        system_bid = build(
          :bid,
          auction: auction,
          user: create(:user),
          current_bid_price: 400,
          system_generated: true,
          max_bid_price: 600
        )
        system_bid.save!
        expect(AutoBidJob).not_to have_been_enqueued
      end
    end
  end
end
