# frozen_string _literal: true
class ProductClient < ApplicationRecord

  def self.get_products(product_ids)
    params = product_ids.map { |id| "product_ids[]=#{id}" }.join('&')
    response = HTTParty.get("http://localhost:3001/products?#{params}")
    JSON.parse(response.body)
  end

end

