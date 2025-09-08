# frozen_string_literal: true

class Bid < ApplicationRecord
  include BidStateMachine

  enum :status, { outdated: 0, active: 1, winning: 2 }

  belongs_to :auction
  belongs_to :user
  has_one :auction_result, foreign_key: :winning_bid_id

  validates :current_bid_price, presence: true,
                                numericality: { greater_than_or_equal_to: 0 }
  validates :max_bid_price, presence: true,
                            numericality: { greater_than_or_equal_to: 0 }, if: :autobid
  validate :price_is_higher_than_current_highest_bid, on: :create
  validate :max_bid_is_higher_than_current_bid_price

  after_create :run_bid_callbacks

  scope :autobid, -> { where(autobid: true) }

  private

  def run_bid_callbacks
    BidProcessingService.new(self).call
  end

  def price_is_higher_than_current_highest_bid
    if auction.current_highest_bid
      if current_bid_price <= auction.current_highest_bid.current_bid_price
        errors.add(:current_bid_price,
                   'must be higher than the current highest bid')
      end
    elsif current_bid_price < auction.starting_price
      errors.add(:current_bid_price, 'must be at least the starting price')
    end
  end

  def max_bid_is_higher_than_current_bid_price
    return unless max_bid_price.present? && max_bid_price < current_bid_price

    errors.add(:max_bid_price, 'cannot be less than the current bid price')
  end
end
