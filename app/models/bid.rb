# frozen_string_literal: true

class Bid < ApplicationRecord
  enum :status, { outdated: 0, active: 1 }
  include AASM

  aasm column: 'status', enum: true do
    state :active, initial: true
    state :outdated # a state to indicate this bid is former bid for a user
    state :winning

    event :outdate do
      transitions from: :active, to: :outdated
    end
    event :win do
      transitions from: :active, to: :winning
    end
  end

  has_many :bid_histories
  belongs_to :auction
  belongs_to :user
  has_one :auction_result, foreign_key: :winning_bid_id

  validates :current_bid_price, presence: true,
                                numericality: { greater_than_or_equal_to: 0 }
  validates :max_bid_price, presence: true,
                            numericality: { greater_than_or_equal_to: 0 }, if: :autobid
  validate :price_is_higher_than_current_highest_bid, on: :create
  validate :max_bid_is_higher_than_current_bid_price

  after_commit :trigger_auto_bidding, on: :create
  after_commit :check_and_process_bid, on: :create
  after_commit :outdate_user_previous_bids, on: :create

  scope :autobid, -> { where(autobid: true) }
  scope :system_generated, -> { where(system_generated: true) }

  private

  def check_and_process_bid
    auction.with_lock do
      auction.update!(current_highest_bid: self)
    end
  end

  def outdate_user_previous_bids
    auction.bids.where(user_id: user_id, status: :active).where.not(id: id).find_each do |bid|
      bid.outdate! if bid.may_outdate?
    end
  end

  def trigger_auto_bidding
    return if system_generated
    AutoBidJob.perform_async(auction.id) if auction.active?
  end

  def price_is_higher_than_current_highest_bid
    if auction.current_highest_bid
      errors.add(:current_bid_price, 'must be higher than the current highest bid') if current_bid_price <= auction.current_highest_bid.current_bid_price
    elsif current_bid_price < auction.starting_price
      errors.add(:current_bid_price, 'must be at least the starting price')
    end
  end

  def max_bid_is_higher_than_current_bid_price
    return unless max_bid_price.present? && max_bid_price < current_bid_price
    errors.add(:max_bid_price, 'cannot be less than the current bid price')
  end
end
