require 'rails_helper'

RSpec.describe Carts::AddItemService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, price: 50.0) }

  describe '.call' do
    context 'when adding a new product' do
      it 'creates a new cart item' do
        result = nil
        expect {
          result = described_class.call(cart: cart, product_id: product.id, quantity: 2)
        }.to change(CartItem, :count).by(1)

        expect(result).to be_success
        expect(cart.cart_items.first.quantity).to eq(2)
      end
    end

    context 'when adding an existing product' do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 1)
      end

      it 'updates the quantity of the existing item' do
        result = nil
        expect {
          result = described_class.call(cart: cart, product_id: product.id, quantity: 3)
        }.not_to change(CartItem, :count)

        expect(result).to be_success
        expect(cart.cart_items.reload.first.quantity).to eq(4)
      end
    end

    context 'with invalid inputs' do
      it 'returns a failure result if quantity is zero' do
        result = described_class.call(cart: cart, product_id: product.id, quantity: 0)
        expect(result).not_to be_success
        expect(result.error).to eq('Invalid quantity')
      end

      it 'returns a failure result if cart is missing' do
        result = described_class.call(cart: nil, product_id: product.id, quantity: 1)
        expect(result).not_to be_success
        expect(result.error).to eq('Cart not found')
      end
    end
  end
end
