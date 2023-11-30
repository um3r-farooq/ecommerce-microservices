require 'rails_helper'

RSpec.describe "Products", type: :request do
  describe "GET /products" do
    before { create_list(:product, 5) }

    it "should get all products" do
      get "/products"
      p "here is #{response}"
      expect(response).to have_http_status(:ok)
      expect(json_response.count).to eq(5)
    end
  end

  describe "POST /products" do

    let(:valid_attributes) { attributes_for(:product) }
    let(:valid_file_path) { Rails.root.join("spec", "fixtures", "files", "image.png") }
    let(:invalid_file_path) { Rails.root.join("spec", "fixtures", "files", "cspbook.pdf") }
    let(:valid_token) { JWTHelper.generate_jwt_token({user_id: 1}) }
    let(:valid_headers) { { "Authorization": "Bearer #{valid_token}" }}

    context "with valid attributes" do

      it "should create a product" do
        post "/products", params: valid_attributes, headers: valid_headers
        expect(response).to have_http_status(:created)
        expect(json_response["name"]).to eq(valid_attributes[:name])
        expect(json_response["description"]).to eq(valid_attributes[:description])
        expect(json_response["price"]).to eq(valid_attributes[:price])
      end

      it "should create a product with image" do
        post "/products", params: valid_attributes.merge(images: [fixture_file_upload(valid_file_path, "image/png")]), headers: valid_headers
        expect(response).to have_http_status(:created)
        expect(json_response["image_urls"].count).to eq(1)
      end
    end

    context "with invalid attributes" do

      it "should return error for missing product name" do
        post "/products", params: valid_attributes.merge(name: ""), headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Name can't be blank")
      end

      it "should return error for wrong product image type" do
        post "/products", params: valid_attributes.merge(images: [fixture_file_upload(invalid_file_path, "application/pdf")]), headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Images Must be a JPEG, PNG or GIF")
      end

      it "should return error for missing product price" do
        post "/products", params: valid_attributes.merge(price: nil), headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Price can't be blank")
      end

      it "should return error for short product description" do
        post "/products", params: valid_attributes.merge(description: "test desc"), headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Description is too short (minimum is 10 characters)")
      end
    end
  end

  describe "GET /products/id" do
    let!(:product) { create(:product) }

    it "should return a product" do
      get "/products/#{product.id}"
      expect(response).to have_http_status(:ok)
      expect(json_response["name"]).to eq(product.name)
      expect(json_response["description"]).to eq(product.description)
      expect(json_response["price"]).to eq(product.price)
    end

    it "should return not found" do
      get "/products/100"
      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to include("Product not found")
    end
  end

  describe "PUT /products/id" do
    let!(:product) { create(:product) }
    let(:valid_attributes) {
      attributes_for(:product, id:product.id, name: product.name, description: product.description, price: product.price)
    }
    let(:valid_token) { JWTHelper.generate_jwt_token({user_id: 1}) }
    let(:valid_headers) { { "Authorization": "Bearer #{valid_token}" }}

    context "with valid attributes" do
      it "should return a product" do
        put "/products/#{valid_attributes[:id]}", params: valid_attributes.merge(name: "modified name"), headers: valid_headers
        expect(response).to have_http_status(:created)
        expect(json_response["name"]).to eq("modified name")
        expect(json_response["description"]).to eq(valid_attributes[:description])
        expect(json_response["price"]).to eq(valid_attributes[:price])
      end

      it "should return not found" do
        put "/products/100", headers: valid_headers
        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to include("Product not found")
      end
    end

    context "with invalid attributes" do
      it "should return error for missing product name" do
        put "/products/#{valid_attributes[:id]}", params: valid_attributes.merge(name: ""), headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Name can't be blank")
      end

      it "should return error for missing product price" do
        put "/products/#{valid_attributes[:id]}", params: valid_attributes.merge(price: nil), headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Price can't be blank")
      end

      it "should return error for short product description" do
        put "/products/#{valid_attributes[:id]}", params: valid_attributes.merge(description: "test desc"), headers: valid_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to include("Description is too short (minimum is 10 characters)")
      end
    end
  end

  describe "DELETE /products/id" do
    let!(:product) { create(:product) }
    let(:valid_token) { JWTHelper.generate_jwt_token({user_id: 1}) }
    let(:valid_headers) { { "Authorization": "Bearer #{valid_token}" }}

    it "should delete a product" do
      delete "/products/#{product.id}", headers: valid_headers
      expect(response).to have_http_status(:no_content)
      expect(Product.count).to eq(0)
    end

    it "should return not found" do
      delete "/products/100", headers: valid_headers
      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to include("Product not found")
    end
  end
end