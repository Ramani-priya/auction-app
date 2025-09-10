# frozen_string_literal: true

class AddIndexesToAuctions < ActiveRecord::Migration[7.0]
  def change
    add_index :auctions, %i[status start_time end_time],
              name: 'index_auctions_on_status_and_start_time_and_end_time'
  end
end
