# frozen_string_literal: true

class EndAuctionsJob
  include Sidekiq::Job

  def perform
    Auction.pending_to_end
      .find_each(batch_size: 500) do |auction|
        EndAuctionService.new(auction).call
      end
  end
end
