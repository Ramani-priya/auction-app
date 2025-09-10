class AuctionEndedMailer < ApplicationMailer
  default from: 'no-reply@bidsphere.com'

  def seller_email
    @auction = params[:auction]
    @seller = params[:seller]
    mail(to: @seller.email, subject: "Your auction #{@auction.title} has ended")
  end
end
