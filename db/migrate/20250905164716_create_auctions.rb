# frozen_string_literal: true

class CreateAuctions < ActiveRecord::Migration[7.0]
  def change
    create_table :auctions do |t|
      t.references :item, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.decimal :starting_price, precision: 10, scale: 2, null: false
      t.decimal :min_selling_price, precision: 10, scale: 2, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
