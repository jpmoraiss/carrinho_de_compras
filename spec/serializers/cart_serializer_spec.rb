require 'rails_helper'

RSpec.describe CartSerializer do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, name: 'Phone', price: 1000.0) }

  before do
    create(:cart_item, cart: cart, product: product, quantity: 2)
  end

  describe '#render' do
    subject(:rendered_json) do
      cart.reload
      described_class.render(cart)
    end

    it 'returns the correct structure' do
      expect(rendered_json).to include(:id, :products, :total_price)
    end

    it 'serializes items correctly' do
      product_json = rendered_json[:products].first
      expect(product_json[:id]).to eq(product.id)
      expect(product_json[:name]).to eq('Phone')
      expect(product_json[:quantity]).to eq(2)
      expect(product_json[:unit_price]).to eq(1000.0)
      expect(product_json[:total_price]).to eq(2000.0)
    end

    it 'calculates total price correctly' do
      expect(rendered_json[:total_price]).to eq(2000.0)
    end

    it 'returns prices as floats' do
      expect(rendered_json[:total_price]).to be_a(Float)
      expect(rendered_json[:products].first[:unit_price]).to be_a(Float)
    end
  end
end
