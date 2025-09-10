# frozen_string_literal: true

class AuctionResultNotifier
  require 'net/http'
  require 'json'
  WEBHOOK_CONFIG = Rails.application.config_for(:webhooks)

  def self.notify(auction)
    return unless auction.current_highest_bid

    payload = {
      auction_id: auction.id,
      winner_id: auction.current_highest_bid.user_id,
      final_price: auction.current_highest_bid.current_bid_price,
      ended_at: auction.end_time || Time.current,
    }

    send_webhook(auction, payload)
    send_emails(auction)
  rescue StandardError => e
    Rails.logger.error "Failed to notify external system: #{e.class} - #{e.message}"
  end

  def self.send_webhook(_auction, payload)
    webhook_url = WEBHOOK_CONFIG[:auction_result_url]
    return if webhook_url.blank?

    headers = { 'Authorization' => "Bearer #{WEBHOOK_CONFIG[:auction_result_token]}" }
    WebhookClient.send(webhook_url, payload, headers)
  end

  def self.send_emails(auction)
    winner = auction.current_highest_bid.user
    seller = auction.seller
    AuctionResultMailer.with(auction: auction, winner: winner,
                             seller: seller).winner_email.deliver_later
    AuctionResultMailer.with(auction: auction, winner: winner,
                             seller: seller).seller_email.deliver_later
  end
end
