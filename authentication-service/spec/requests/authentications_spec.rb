require 'rails_helper'

RSpec.shared_examples 'a registration error' do |error_message, extra_params|
  it "when #{error_message}" do
    post "/register", params: {}.merge(extra_params)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json_response["error"]).to include(error_message)
  end
end

RSpec.shared_examples 'a login error' do |error_message, extra_params|
  it 'when #{error_message' do
    post '/login', params: {}.merge(extra_params)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json_response["error"]).to include(error_message)
  end
end

RSpec.describe "Authentications", type: :request do

  before do
    post '/register', params: {
      email: "alreadytaken@example.com",
      password: "password",
      password_confirmation: "password"
    }
    # create(:user, email: "alreadytaken@example.com")
  end

  describe "POST /register" do
    let(:valid_attributes) do
      attributes_for(:user,  password_confirmation: "password")
    end

    # let(:invalid_attributes) do
    #   {
    #     email: "test@example.com",
    #     password: "password",
    #     password_confirmation: "wrong password"
    #   }
    # end

    context "with valid parameters" do
      before do
        post "/register", params: valid_attributes
      end

      it "creates a User" do
        expect(User.count).to be(2) # one user is already created in before
        expect(User.last.email).to eq(valid_attributes[:email])
      end

      it "returns a JWT token" do
        expect(response).to have_http_status(:created)
        expect(json_response["token"]).not_to be_nil
      end

      it "returns a success message" do
        expect(json_response["message"]).to eq("User Created!")
      end
    end

    context "with invalid parameters" do
      it_behaves_like 'a registration error', 'Email has already been taken', email: "alreadytaken@example.com"
      it_behaves_like 'a registration error', "Email can't be blank", email: ''
      it_behaves_like 'a registration error', "Password can't be blank", password: '', password_confirmation: ''
      it_behaves_like 'a registration error', "Password confirmation doesn't match Password", email: 'test@example.com',password: "dafdfadf", password_confirmation: "pass"
      it_behaves_like 'a registration error', "Email is invalid", email: 'test@.com'
      it_behaves_like 'a registration error', "Email is invalid", email: 'test@gmail#.com'
      it_behaves_like 'a registration error', "Password is too short (minimum is 8 characters)", password: 'short', password_confirmation: 'short'
    end

    #   it "returns an error if email is taken" do
    #     post "/register", params: invalid_attributes
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(json_response["error"]).to include("Email has already been taken")
    #   end
    #
    # end
    # context "with invalid parameters" do
    #
    #   before do
    #     post '/register', params: invalid_attributes
    #   end
    #
    #   it "does not create a User" do
    #     expect(User.count).to be(0)
    #   end
    #
    #   it "returns an error if password doesn't match" do
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(json_response["error"]).to include("Password confirmation doesn't match Password")
    #   end
    #
    #   it "returns an error if email is blank" do
    #     post '/register', params: {email: "", password:"password", password_confirmation: "password"}
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(json_response["error"]).to include("Email can't be blank")
    #   end
    #
    #   it "returns an error if email is invalid" do
    #     post '/register', params: {email: "test@test", password:"password", password_confirmation: "password"}
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(json_response["error"]).to include("Email is invalid")
    #   end
    #
    #
    #   it "returns an error if password is less than 8 characters" do
    #     post '/register', params: {email: "test@test.com", password:"dummy", password_confirmation: "dummy"}
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(json_response["error"]).to include("Password is too short (minimum is 8 characters)")
    #   end
    #
    #   it "returns an error if password is empty" do
    #     post '/register', params: {email: "test@test.com", password:"", password_confirmation: ""}
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(json_response["error"]).to include("Password can't be blank")
    #   end
    #
    #   it "returns an error if request body is empty" do
    #     post "/register", params: {}
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(json_response["error"]).to match_array(["Password can't be blank", "Email can't be blank", "Email is invalid","Password is too short (minimum is 8 characters)"])
    #   end

  end

  describe "POST /login" do
    let(:valid_attributes) do
      attributes_for(:user,email: "alreadytaken@example.com")
    end


    context "login with valid attributes" do

      before do
        post '/login', params: valid_attributes
      end

      it "should login user successfully" do
        expect(User.last.email).to eq(valid_attributes[:email])
      end

      it "should return a JWT token" do
        expect(response).to have_http_status(:ok)
        expect(json_response["token"]).not_to be_nil
      end

      it "should return a success message" do
        expect(json_response["message"]).to eq("User Logged in!")
        end
    end

    context "login with invalid attributes" do
      it_behaves_like 'a login error', "Invalid email or password!", email: "test@gmail.com"
      it_behaves_like 'a login error', "Invalid email or password!", email: "existing@example.com", password: "test"
      it_behaves_like 'a login error', "Invalid email or password!", email: "", password: "password"
    end

  end
end
