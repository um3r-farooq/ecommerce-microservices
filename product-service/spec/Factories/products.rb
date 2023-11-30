FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 0..100.0, as_string: true) }

    transient do
      image_path nil
    end

    after(:create) do |product, evaluator|
      if evaluator.image_path.present?
        product.image.attach(io: File.open(evaluator.image_path), filename: 'image.png', content_type: 'image/png')
      end
    end
  end
end