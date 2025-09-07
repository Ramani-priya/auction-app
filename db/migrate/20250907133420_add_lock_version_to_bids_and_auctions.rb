class AddLockVersionToBidsAndAuctions < ActiveRecord::Migration[7.0]
  def change
    add_column :bids, :lock_version, :integer, default: 0, null: false
    add_column :auctions, :lock_version, :integer, default: 0, null: false
  end
end
