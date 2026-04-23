require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe "associations" do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe "validations" do
    it { should validate_numericality_of(:quantity).is_greater_than(0).only_integer }
  end

  describe "#total_price" do
    it "calculates product price times quantity" do
      product = create(:product, price: 10.5)
      cart_item = build(:cart_item, product: product, quantity: 3)
      expect(cart_item.total_price).to eq(31.5)
    end
  end

  describe "callbacks" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }

    it "updates cart total_price after save" do
      cart_item = build(:cart_item, cart: cart, product: product, quantity: 2)
      expect { cart_item.save }.to change { cart.reload.total_price }.from(0).to(20.0)
    end

    it "updates cart total_price after destroy" do
      cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)
      expect { cart_item.destroy }.to change { cart.reload.total_price }.from(20.0).to(0)
    end

    it "updates cart total_price after update" do
      cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)
      expect { cart_item.update(quantity: 5) }.to change { cart.reload.total_price }.from(20.0).to(50.0)
    end
  end
end
