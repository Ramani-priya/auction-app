class MoveDescriptionToAuctions < ActiveRecord::Migration[7.0]
  def change
    add_column :auctions, :description, :text
    remove_column :items, :description
  end
end
