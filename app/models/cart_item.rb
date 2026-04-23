class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  after_save :update_cart_total_price
  after_destroy :update_cart_total_price

  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  def total_price
    product.price.to_f * quantity
  end

  private

  def update_cart_total_price
    cart.update_total_price!
  end
end
