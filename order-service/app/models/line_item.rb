class LineItem < ApplicationRecord
  belongs_to :order

  after_save :update_total_price

  validates :price, length: { minimum: 1 }
  validates :quantity, length: {minimum: 1}

  def update_total_price
    updated_price = self.order.line_items.sum do |item|
      item.price * item.quantity
    end

    self.order.update(total_price: updated_price)
  end

end
