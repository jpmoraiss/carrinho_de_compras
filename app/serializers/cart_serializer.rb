class CartSerializer
  def initialize(cart)
    @cart = cart
  end

  def self.render(cart)
    new(cart).render
  end

  def render
    {
      id: @cart.id,
      products: serialize_items,
      total_price: @cart.total_price.to_f
    }
  end

  private

  def serialize_items
    @cart.cart_items.includes(:product).map do |item|
      {
        id: item.product.id,
        name: item.product.name,
        quantity: item.quantity,
        unit_price: item.product.price.to_f,
        total_price: item.total_price.to_f
      }
    end
  end
end
