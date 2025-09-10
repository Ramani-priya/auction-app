# frozen_string_literal: true

class AutoBidTriggerService
  def initialize(auction)
    @auction = auction
  end

  def call
    return if @auction.current_highest_bid&.system_generated?
    return unless @auction.in_progress?

    AutoBidJob.perform_async(@auction.id)
  end
end
