# frozen_string_literal: true

class AuctionResultMailer < ApplicationMailer
  default from: 'no-reply@bidsphere.com'

  def winner_email
    @auction = params[:auction]
    @winner = params[:winner]
    mail(to: @winner.email,
         subject: "Congratulations! You won the auction #{@auction.title}")
  end

  def seller_email
    @auction = params[:auction]
    @seller = params[:seller]
    mail(to: @seller.email,
         subject: "Your auction #{@auction.title} has ended with a winner")
  end
end
