require 'rails_helper'

RSpec.describe "Carts", type: :request do
  let(:product) { create(:product, name: "Mouse", price: 10.0) }

  describe "POST /cart (create)" do
    it "creates a cart and adds a product" do
      post "/cart", params: { product_id: product.id, quantity: 2 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to be_present
      expect(json["products"].first["id"]).to eq(product.id)
      expect(json["products"].first["quantity"]).to eq(2)
      expect(json["total_price"]).to eq(20.0)
    end

    it "returns 422 if parameters are missing" do
      post "/cart", params: { product_id: product.id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq('Missing product_id or quantity')
    end

    it "returns 404 if product does not exist" do
      post "/cart", params: { product_id: 999999, quantity: 1 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq('Product not found')
    end
  end

  describe "POST /cart/add_item" do
    it "adds a new item to the existing cart" do
      cart = create(:cart)
      create(:cart_item, cart: cart, product: product, quantity: 1)
      new_product = create(:product, name: "Keyboard", price: 50.0)
      
      allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      post "/cart/add_item", params: { product_id: new_product.id, quantity: 1 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["products"].size).to eq(2)
      expect(json["total_price"]).to eq(60.0)
    end

    context 'when adding product that already exists' do
      it "update the quantity" do
        cart = create(:cart)
        create(:cart_item, cart: cart, product: product, quantity: 1)
        
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
        post "/cart/add_item", params: { product_id: product.id, quantity: 3 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["products"].size).to eq(1)
        expect(json["products"][0]["quantity"]).to eq(4)
        expect(json["total_price"]).to eq(40.0)
      end
    end

    context 'when there is no cart' do
      it "returns an error" do
        new_product = create(:product, name: "Keyboard", price: 50.0)        
        post "/cart/add_item", params: { product_id: new_product.id, quantity: 1 }

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq('Cart not found')
      end
    end

    context 'when quantity is invalid' do
      it "returns an error when quantity is -1" do
        cart = create(:cart)
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
        
        post "/cart/add_item", params: { product_id: product.id, quantity: -1 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq('Invalid quantity')
      end
    end

    context 'when product does not exist' do
      it "returns 404" do
        cart = create(:cart)
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
        
        post "/cart/add_item", params: { product_id: 999999, quantity: 1 }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq('Product not found')
      end
    end

    context 'when parameters are missing' do
      it "returns 422" do
        cart = create(:cart)
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
        
        post "/cart/add_item", params: { product_id: product.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq('Missing product_id or quantity')
      end
    end
  end

  describe "GET /cart" do
    it "shows the current cart using session" do
      post "/cart", params: { product_id: product.id, quantity: 1 }
      get "/cart"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["products"].first["name"]).to eq("Mouse")
    end
  end

  describe "DELETE /cart/:product_id" do
    it "removes a product from the cart" do
      post "/cart", params: { product_id: product.id, quantity: 1 }
      delete "/cart/#{product.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["products"].size).to eq(0)
    end

    it "returns 404 if product is not in cart" do
      post "/cart", params: { product_id: product.id, quantity: 1 }
      another = create(:product)
      delete "/cart/#{another.id}"
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Product not listed in cart")
    end
  end
end

