require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe "associations" do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe "constants" do
    it "has ABANDONED_THRESHOLD set to 3 hours" do
      expect(Cart::ABANDONED_THRESHOLD).to eq(3.hours)
    end

    it "has REMOVABLE_THRESHOLD set to 7 days" do
      expect(Cart::REMOVABLE_THRESHOLD).to eq(7.days)
    end
  end

  describe "scopes" do
    describe ".abandoned_candidates" do
      it "returns carts not abandoned and updated more than 3 hours ago" do
        abandoned_candidate = create(:cart, updated_at: 4.hours.ago, abandoned_at: nil)
        active_cart = create(:cart, updated_at: 2.hours.ago, abandoned_at: nil)
        already_abandoned = create(:cart, updated_at: 4.hours.ago, abandoned_at: 1.hour.ago)

        expect(Cart.abandoned_candidates).to include(abandoned_candidate)
        expect(Cart.abandoned_candidates).not_to include(active_cart)
        expect(Cart.abandoned_candidates).not_to include(already_abandoned)
      end
    end

    describe ".removable_abandoned" do
      it "returns carts abandoned more than 7 days ago" do
        old_abandoned = create(:cart, abandoned_at: 8.days.ago)
        recent_abandoned = create(:cart, abandoned_at: 6.days.ago)
        not_abandoned = create(:cart, abandoned_at: nil)

        expect(Cart.removable_abandoned).to include(old_abandoned)
        expect(Cart.removable_abandoned).not_to include(recent_abandoned)
        expect(Cart.removable_abandoned).not_to include(not_abandoned)
      end
    end
  end

  describe "#total_price" do
    it "returns the sum of cart_items total_price" do
      cart = create(:cart)
      product = create(:product, price: 10.0)
      product2 = create(:product, price: 20.0)
      create(:cart_item, cart: cart, product: product, quantity: 2)
      create(:cart_item, cart: cart, product: product2, quantity: 1)

      expect(cart.reload.total_price).to eq(40.0)
    end

    it "returns 0 when cart has no items" do
      cart = create(:cart)
      expect(cart.total_price).to eq(0)
    end
  end

  describe "#update_total_price!" do
    it "updates the total_price column" do
      cart = create(:cart)
      product = create(:product, price: 15.0)
      create(:cart_item, cart: cart, product: product, quantity: 2)
      
      cart.update(total_price: 0)
      expect { cart.update_total_price! }.to change { cart.total_price }.from(0).to(30.0)
    end
  end
end
