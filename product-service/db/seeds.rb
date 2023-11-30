# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

30.times do
  product = Product.new(
    name: Faker::Commerce.product_name,
    price: Faker::Commerce.price(range: 0..100.0, as_string: true),
    description: Faker::Lorem.paragraph
  )

  # Attach an image from the fixtures file
  file_path = Rails.root.join("spec", "fixtures", "files", "image.png")
  product.images.attach(io: File.open(file_path), filename: "image.png")

  if product.save!
    puts "Created Product - " + product.name
  end
end
