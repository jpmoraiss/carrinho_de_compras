module Carts
  class AddItemService
    Result = Struct.new(:success, :error, :status) do
      def success?
        success
      end
    end

    def self.call(cart:, product_id:, quantity:)
      new(cart, product_id, quantity).call
    end

    def initialize(cart, product_id, quantity)
      @cart = cart
      @product_id = product_id
      @quantity = quantity&.to_i
    end

    def call
      return Result.new(false, 'Cart not found', :not_found) if @cart.nil?
      return Result.new(false, 'Missing product_id or quantity', :unprocessable_entity) if @product_id.blank? || @quantity.nil?
      return Result.new(false, 'Invalid quantity', :unprocessable_entity) if @quantity <= 0
      return Result.new(false, 'Product not found', :not_found) unless Product.exists?(@product_id)

      cart_item = @cart.cart_items.find_or_initialize_by(product_id: @product_id)
      cart_item.quantity ||= 0
      cart_item.quantity += @quantity
      cart_item.save!

      Result.new(true)
    end
  end
end
