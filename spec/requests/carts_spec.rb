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

    it "returns correct JSON structure as per README" do
      post "/cart", params: { product_id: product.id, quantity: 2 }
      json = JSON.parse(response.body)
      
      expect(json).to include("id", "products", "total_price")
      product_json = json["products"].first
      expect(product_json).to include("id", "name", "quantity", "unit_price", "total_price")
      expect(product_json["unit_price"]).to eq(10.0)
      expect(product_json["total_price"]).to eq(20.0)
    end

    it "returns 422 if parameters are missing" do
      post "/cart", params: { product_id: product.id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq('Missing product_id or quantity')
    end

    it "returns 422 if quantity is zero" do
      post "/cart", params: { product_id: product.id, quantity: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq('Invalid quantity')
    end

    it "returns 422 if quantity is negative" do
      post "/cart", params: { product_id: product.id, quantity: -1 }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 if product does not exist" do
      post "/cart", params: { product_id: 999999, quantity: 1 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq('Product not found')
    end
  end

  describe "POST /cart/add_item" do
    let(:cart) { create(:cart) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:session).and_return({ cart_id: cart.id })
    end

    it "adds a new item to the existing cart" do
      new_product = create(:product, name: "Keyboard", price: 50.0)
      post "/cart/add_item", params: { product_id: new_product.id, quantity: 1 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["products"].size).to eq(1)
      expect(json["total_price"]).to eq(50.0)
    end

    context 'when adding product that already exists' do
      it "increments the quantity" do
        create(:cart_item, cart: cart, product: product, quantity: 1)
        post "/cart/add_item", params: { product_id: product.id, quantity: 3 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["products"][0]["quantity"]).to eq(4)
        expect(json["total_price"]).to eq(40.0)
      end
    end

    context 'when there is no cart' do
      it "returns an error" do
        allow_any_instance_of(ApplicationController).to receive(:session).and_return({})
        post "/cart/add_item", params: { product_id: product.id, quantity: 1 }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq('Cart not found')
      end
    end

    context 'when quantity is invalid' do
      it "returns 422 for zero quantity" do
        post "/cart/add_item", params: { product_id: product.id, quantity: 0 }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 for non-integer quantity" do
        post "/cart/add_item", params: { product_id: product.id, quantity: "invalid" }
        # Service converts to_i, "invalid".to_i is 0, which returns Invalid quantity
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /cart" do
    it "shows the current cart content" do
      post "/cart", params: { product_id: product.id, quantity: 2 }
      get "/cart"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["products"].first["name"]).to eq("Mouse")
      expect(json["total_price"]).to eq(20.0)
    end

    it "returns empty structure when no cart in session" do
      get "/cart"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["products"]).to eq([])
      expect(json["total_price"]).to eq(0.0)
    end
  end

  describe "DELETE /cart/:product_id" do
    before do
      post "/cart", params: { product_id: product.id, quantity: 1 }
    end

    it "removes a product and updates total price" do
      delete "/cart/#{product.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["products"]).to be_empty
      expect(json["total_price"]).to eq(0.0)
    end

    it "returns 404 if product is not in cart" do
      another = create(:product)
      delete "/cart/#{another.id}"
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["error"]).to eq("Product not listed in cart")
    end

    it "handles removal of one product when multiple types exist" do
      p2 = create(:product, price: 5.0)
      post "/cart/add_item", params: { product_id: p2.id, quantity: 1 }
      
      delete "/cart/#{product.id}"
      
      json = JSON.parse(response.body)
      expect(json["products"].size).to eq(1)
      expect(json["products"].first["id"]).to eq(p2.id)
      expect(json["total_price"]).to eq(5.0)
    end
  end
end

