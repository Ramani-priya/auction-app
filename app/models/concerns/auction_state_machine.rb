# frozen_string_literal: true

module AuctionStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: 'status', enum: true do
      state :draft, initial: true
      state :active
      state :ended, after_enter: :end_auction_callback
      state :sold, after_enter: :sold_auction_callback

      event :end_auction do
        transitions from: :active, to: :sold, guard: :has_winner?
        transitions from: :active, to: :ended
      end

      event :start_auction do
        transitions from: :draft, to: :active
        transitions from: :ended, to: :active, guard: :no_winner?
      end
    end

    private

    def end_auction_callback
      AuctionEndNotifier.notify(self)
    end

    def sold_auction_callback
      return unless current_highest_bid
      return if current_highest_bid.current_bid_price < min_selling_price

      ActiveRecord::Base.transaction do
        create_auction_result(
          winning_bid: current_highest_bid,
          winner: current_highest_bid.user,
          final_price: current_highest_bid.current_bid_price,
        )
        current_highest_bid.win!
        NotifyWinnerJob.perform_async(id)
      end
    end

    def no_winner?
      !has_winner?
    end

    def has_winner?
      @has_winner ||= current_highest_bid.present? && current_highest_bid.current_bid_price >= min_selling_price
    end
  end
end
