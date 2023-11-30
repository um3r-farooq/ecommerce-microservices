class Product < ApplicationRecord
  has_many_attached :images, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, length: { minimum: 10 }
  validates :price, presence: true, numericality: {greater_than: 0}

  validate :image_type, if: :image_attached?


  def image_attached?
    images.attached?
  end
  def image_type
    # check for certain types eg png. jpg, jpeg etc
    # adding error messages
    images.each do |image|
      unless image.content_type.in?(%w[images/png image/jpeg image/gif])
        errors.add(:images, "Must be a JPEG, PNG or GIF")
      end
    end
  end
end
