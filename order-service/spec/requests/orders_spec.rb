require 'rails_helper'

RSpec.describe "Orders", type: :request do
  describe "GET /index" do
    let(:valid_token) { JWTHelper.generate_jwt_token({user_id: 1}) }
    let(:valid_headers) { { "Authorization": "Bearer #{valid_token}" }}
    it 'should return all orders for this user' do
      get '/orders',headers: valid_headers
      expect(response).to have_http_status(:ok)
    end
  end
end
