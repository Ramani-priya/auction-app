# spec/mailers/auction_ended_mailer_spec.rb
require 'rails_helper'

RSpec.describe AuctionEndedMailer, type: :mailer do
  describe '#seller_email' do
    let(:seller) { create(:user, email: 'seller@example.com') }
    let(:auction) { create(:auction, seller: seller) }
    let(:mail) { described_class.with(auction: auction, seller: seller).seller_email }

    it 'renders the headers' do
      expect(mail.subject).to eq("Your auction #{auction.title} has ended")
      expect(mail.to).to eq([seller.email])
      expect(mail.from).to eq(['no-reply@bidsphere.com'])
    end

    it 'includes auction details in the body' do
      expect(mail.body.encoded).to include("Your auction: <strong>#{auction.title}</strong> has ended.")
      expect(mail.body.encoded).to include("Unfortunately, there were no winning bids.")
    end
  end
end
