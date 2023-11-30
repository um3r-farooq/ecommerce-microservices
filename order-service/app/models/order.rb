class Order < ApplicationRecord
  has_many :line_items, dependent: :destroy

  VALID_STATUSES = %w[CART PENDING COMPLETE CANCELLED]

  validates :status, inclusion: { in: VALID_STATUSES }

end
