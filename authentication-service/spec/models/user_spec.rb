require 'rails_helper'

RSpec.describe User, type: :model do

  describe "validations" do

    it 'is valid with valid attributes' do
      user = build(:user, password_confirmation: "password" )
      expect(user).to be_valid
    end

    it "is not valid without an email" do
      user = build(:user, email:nil)
      expect(user).not_to be_valid
    end

    it "is not valid when email doesnt match the format" do
      user = build(:user, email: "email.com")
      expect(user).not_to be_valid
    end

    it "is not valid with a duplicate email" do
      create(:user, email: "test@test.com", password_confirmation: "password")
      user = build(:user,  email: "test@test.com", password_confirmation: "password")
      expect(user).not_to be_valid
    end

  end
end