# frozen_string_literal: true

class Auction < ApplicationRecord
  include AuctionStateMachine

  enum :status, { draft: 0, active: 1, ended: 2, sold: 3 }

  validates :starting_price, :min_selling_price, :start_time, :end_time,
            presence: true
  validates :starting_price, :min_selling_price,
            numericality: { greater_than_or_equal_to: 0 }
  validates :end_time, comparison: { greater_than: :start_time }
  validate :min_selling_price_gte_starting_price

  has_many :bids
  belongs_to :item, optional: true
  belongs_to :seller, class_name: 'User'
  has_one :auction_result
  belongs_to :current_highest_bid, class_name: 'Bid', optional: true

  after_update_commit :trigger_auto_bidding

  scope :pending_to_end, lambda {
    active.where(end_time: ..Time.current)
  }

  delegate :title, to: :item, allow_nil: true

  def trigger_auto_bidding
    if saved_change_to_current_highest_bid_id? && current_highest_bid.present? && active?
      AutoBidTriggerService.new(self).call
    end
  end

  def minimum_increment
    increments = {
      0.99 => 0.05,
      4.99 => 0.25,
      24.99 => 0.50,
      99.99 => 1,
      249.99 => 2,
      499.99 => 5,
      Float::INFINITY => 10,
    }
    increments.detect do |max, _|
      current_highest_bid.current_bid_price <= max
    end[1]
  end

  private

  def min_selling_price_gte_starting_price
    return if min_selling_price.nil? || starting_price.nil?
    return unless min_selling_price < starting_price

    errors.add(:min_selling_price,
               'must be greater than or equal to starting price')
  end
end
