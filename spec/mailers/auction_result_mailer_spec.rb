# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AuctionResultMailer, type: :mailer do
  let(:winner) { create(:user, email: "winner@example.com") }
  let(:seller) { create(:user, email: "seller@example.com") }
  let(:auction) do
    create(:auction).tap do |a|
      create(:bid, auction: a, user: winner, current_bid_price: 100)
      a.reload
    end
  end

  before do
    auction.update(current_highest_bid: auction.bids.last)
  end

  describe '#winner_email' do
    let(:mail) { described_class.with(auction: auction, winner: winner).winner_email }

    it 'renders the headers' do
      expect(mail.subject).to eq("Congratulations! You won the auction #{auction.title}")
      expect(mail.to).to eq([winner.email])
      expect(mail.from).to eq(['no-reply@bidsphere.com'])
    end

    it 'includes auction details and price' do
      expect(mail.body.encoded).to include("Congratulations!")
      expect(mail.body.encoded).to include("You have won the auction: <strong>#{auction.title}</strong>.")
      expect(mail.body.encoded).to include("The final price is <strong>$#{auction.current_highest_bid.current_bid_price}</strong>.")
    end
  end

  describe '#seller_email' do
    let(:mail) { described_class.with(auction: auction, seller: seller).seller_email }

    it 'renders the headers' do
      expect(mail.subject).to eq("Your auction #{auction.title} has ended with a winner")
      expect(mail.to).to eq([seller.email])
      expect(mail.from).to eq(['no-reply@bidsphere.com'])
    end

    it 'includes auction result details' do
      expect(mail.body.encoded).to include("Your auction: <strong>#{auction.title}</strong> has ended")
      expect(mail.body.encoded).to include("Final price: <strong>$#{auction.current_highest_bid.current_bid_price}</strong>")
      expect(mail.body.encoded).to include("Winning bidder: <strong>#{auction.current_highest_bid.user.email}</strong>")
      expect(mail.body.encoded).to include("Thank you for using our platform!")
    end
  end

  context 'when there are no winning bids' do
    let(:auction) { create(:auction) } # No bids created

    it 'informs the seller there is no winner' do
      mail = described_class.with(auction: auction, seller: seller).seller_email
      expect(mail.body.encoded).to include("Unfortunately, there were no winning bids")
    end
  end
end
