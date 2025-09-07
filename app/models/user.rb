# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :auctions, foreign_key: 'seller_id', class_name: 'Auction', dependent: :destroy
  has_many :bids, class_name: 'Bid', dependent: :destroy
  has_many :won_auctions, -> { where(bids: { status: 'won' }) }, through: :bids, source: :auction
end
