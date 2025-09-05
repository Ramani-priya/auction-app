# app/sidekiq/auction_notifier_job.rb
class AuctionNotifierJob
  include Sidekiq::Job

  def perform(auction_id, user_id)
    auction = Auction.find(auction_id)
    user = User.find(user_id)

    # Example: send email/notification
    puts "Auction #{auction.title} won by #{user.email}"
  end
end
