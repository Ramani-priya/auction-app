# frozen_string_literal: true

module AuctionErrors
  class AuctionBidCreationError < StandardError; end
  class AuctionInactiveError < StandardError; end
  class AuctionAutoBidError < StandardError; end
end
