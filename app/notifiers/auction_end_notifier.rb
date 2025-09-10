class AuctionEndNotifier
  def self.notify(auction)
    return unless auction.ended? 
    payload = {
      auction_id: auction.id,
      ended_at: auction.end_time || Time.current
    }
    send_emails(auction)
  rescue StandardError => e
    Rails.logger.error "Failed to notify external system: #{e.class} - #{e.message}"
  end

  private

  def self.send_emails(auction)
    seller = auction.seller

    AuctionEndedMailer.with(auction: auction, seller: seller).seller_email.deliver_later
  end
end
