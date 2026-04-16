# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


[
  { name: 'iPhone 17 Pro Max', price: 11999.99 },
  { name: 'Xiamo Mi 30 Pro Plus Master Ultra', price: 999.99 },
  { name: 'Samsung Galaxy S25 Ultra', price: 12999.99 }
].each do |product_attrs|
  Product.find_or_create_by!(name: product_attrs[:name]) do |product|
    product.price = product_attrs[:price]
  end
end

puts "Seeds created successfully!"
