
class OrdersController < ApplicationController

  before_action :authenticate_user
  before_action :set_order, only: [:index,:destroy,:update]

  def index
    product_ids = @order.line_items.pluck(:product_id)
    products = ProductClient.get_products(product_ids)
    products.map! do |product|
      line_item = @order.line_items.find_by(product_id: product["id"])
      product.merge(quantity: line_item[:quantity])
    end
    render json:  {order: @order, products: products }
  end

  def create
   add_to_cart
  end

  def destroy
    line_item = @order.line_items.find_by(product_id: order_params[:product_id])
    line_item.destroy
    render json: { message: 'Item deleted successfully!' }
  end

  def update
    line_item = @order.line_items.find_by(product_id: order_params[:product_id])
    line_item.update(quantity: order_params[:quantity])
    render json: {order: @order, product: @order.line_items}
  end

  private
  def add_to_cart
    order = Order.find_or_initialize_by(user_id: @current_user_id, status: 'CART')
    line_item = order.line_items.find_by(product_id: order_params[:product_id])

    if line_item
      line_item.update(quantity: line_item[:quantity] + order_params[:quantity])
    else
      order.line_items.build(order_params)
      order.save
    end
    render json: {order: order,product: order.line_items}
  end
  def order_params
    params.permit(:product_id,:price,:quantity)
  end

  def set_order
    @order = Order.find_by(user_id: @current_user_id, status: 'CART')
  end


end
