# frozen_string_literal: true
module AuctionsHelper
  def auction_current_price(auction)
    price = auction.current_highest_bid&.current_bid_price || auction.starting_price
    number_to_currency(price)
  end

  def auction_description(auction, show_description)
    return unless show_description
    content_tag(:p, auction.description, class: "card-description")
  end

  def auction_price(auction, show_price)
    return unless show_price
    content_tag(:p, "Current Price: #{auction_current_price(auction)}", class: "card-price")
  end

  def auction_details_link(auction, show_details)
    return unless show_details
    link_to "View Details", auction_path(auction), class: "card-button"
  end

  def auction_publish_button(auction, show_publish)
    return unless show_publish
    button_to "Publish", publish_auction_path(auction), method: :patch, class: "card-button"
  end
end
