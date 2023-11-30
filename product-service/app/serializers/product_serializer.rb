include Rails.application.routes.url_helpers

class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price, :images_urls

  def images_urls
    object.images.map {|image| url_for(image) if image} || []
  end
end