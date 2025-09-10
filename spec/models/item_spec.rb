# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item do
  describe 'valid factory' do
    let(:item) { create(:item) }

    it 'is valid with valid attributes' do
      expect(item).to be_valid
    end
  end
end
