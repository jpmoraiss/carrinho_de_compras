class CartsController < ApplicationController
  before_action :set_cart

  def show
    if @cart
      render json: CartSerializer.render(@cart)
    else
      render json: { id: nil, products: [], total_price: 0.0 }, status: :ok
    end
  end

  def add_item
    render json: { error: 'Cart not found' }, status: :not_found and return unless @cart

    result = Carts::AddItemService.call(cart: @cart, product_id: item_params[:product_id], quantity: item_params[:quantity])
    handle_result(result)
  end

  def create
    @cart ||= Cart.create!.tap { |c| session[:cart_id] = c.id }

    result = Carts::AddItemService.call(cart: @cart, product_id: item_params[:product_id], quantity: item_params[:quantity])
    handle_result(result)
  end

  def remove_product
    render json: { error: "Cart not found" }, status: :not_found and return unless @cart

    cart_item = @cart.cart_items.find_by(product_id: item_params[:product_id])
    render json: { error: 'Product not listed in cart' }, status: :not_found and return unless cart_item

    cart_item.destroy
    render json: CartSerializer.render(@cart), status: :ok
  end

  private

  def handle_result(result)
    if result.success?
      render json: CartSerializer.render(@cart), status: :ok
    else
      render json: { error: result.error }, status: result.status
    end
  end

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id] || item_params[:id])
  end

  def item_params
    params.permit(:id, :product_id, :quantity)
  end
end
