# frozen_string_literal: true

class Auction < ApplicationRecord
  enum :status, { draft: 0, active: 1, ended: 2, sold: 3 }
  include AASM

  MIN_BID_INCREMENT = 2

  aasm column: 'status', enum: true do
    state :draft, initial: true
    state :active
    state :ended
    state :sold, after_enter: :sold_auction_callback

    event :end_auction do
      transitions from: :active, to: :sold, guard: :has_winner?
      transitions from: :active, to: :ended, guard: :no_winner?
    end

    event :start_auction do
      transitions from: :draft, to: :active
      transitions from: :ended, to: :active, guard: :no_winner?
    end
  end

  validates :starting_price, :min_selling_price, :start_time, :end_time,
            presence: true
  validates :starting_price, :min_selling_price,
            numericality: { greater_than_or_equal_to: 0 }
  validates :end_time, comparison: { greater_than: :start_time }
  validate :min_selling_price_gte_starting_price

  has_many :bids
  belongs_to :item, optional: true
  belongs_to :seller, class_name: 'User'
  has_many :bid_histories
  has_one :auction_result
  belongs_to :current_highest_bid, class_name: 'Bid', optional: true

  scope :pending_to_end, lambda {
    where(status: :active).where(end_time: ..Time.current)
  }

  delegate :title, :description, to: :item, allow_nil: true

  def create_bid(user, price)
    transaction do
      outdate_user_previous_bids(user.id)
      new_bid = bids.create!(user: user, current_bid_price: price,
                             status: :active)
      new_bid
    end
  rescue StandardError => e
    Rails.logger.error "Bid failed: #{e.message}"
    nil
  end

  def sold_auction_callback
    unless current_highest_bid && current_highest_bid.current_bid_price >= min_selling_price
      return
    end

    create_auction_result(
      winning_bid: current_highest_bid,
      winner: current_highest_bid.user,
      final_price: current_highest_bid.current_bid_price,
    )
    current_highest_bid.win!
    # Notify winner and seller
  end

  def min_selling_price_gte_starting_price
    return unless min_selling_price < starting_price

    errors.add(:min_selling_price,
               'must be greater than or equal to starting price')
  end

  def minimum_increment
    case current_highest_bid.current_bid_price
    when 0..0.99 then 0.05
    when 1..4.99 then 0.25
    when 5..24.99 then 0.50
    when 25..99.99 then 1
    when 100..249.99 then 2
    when 250..499.99 then 5
    else 10
    end
  end

  private

  def no_winner?
    !has_winner?
  end

  def has_winner?
    current_highest_bid.present? && current_highest_bid.current_bid_price >= min_selling_price
  end

  def outdate_user_previous_bids(user_id)
    bids.where(user_id: user_id).where(status: :active).find_each(&:outdate!)
  end
end
