class NotifyWinnerJob
  include Sidekiq::Job

  def perform(auction_id)
    auction = Auction.find(auction_id)
    AuctionResultNotifier.notify(auction)
  end
end