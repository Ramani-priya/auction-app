# frozen_string_literal: true

class AddIndexToTitle < ActiveRecord::Migration[7.0]
  def change
    add_index :items, %i[title], name: 'index_items_on_title'
  end
end
