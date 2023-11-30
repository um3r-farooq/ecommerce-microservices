class ProductsController < ApplicationController

  before_action :set_product, only: [:show, :destroy, :update]
  before_action :authenticate_user, only: [:create, :destroy, :update]
  def index
    if product_params[:product_ids].present?
        products = Product.where(id: product_params[:product_ids])
        render json: products
    else
      @products = Product.all
      render json: @products
    end
  end

  def show
      render json: @product
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created
    else
      render json: {error: @product.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: {error: @product.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      head :no_content
    else
      head :internal_server_error
    end
  end



  private
  def product_params
   params.permit(:name, :description, :price, images: [], product_ids: [])
  end

  def set_product
    @product = Product.find(params[:id])
  end

end
