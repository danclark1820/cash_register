require 'csv'
require 'pry'

products = {}

ctr = 1
CSV.foreach('products.csv', headers: true) do |row|
  products[('id_' + ctr.to_s).to_sym] = {
    sku: row[0],
    name: row[1],
    wholesale_price: row[2],
    retail_price: row[3]
  }
  ctr += 1
end

counter = 1
puts "Welcome to James' coffee emporium"
products.each do |key, value|
  puts "#{counter}) Add item - #{products[key][:retail_price]} - #{products[key][:name]}"
  counter += 1
end

puts "#{counter}) Complete Sale"
puts "#{counter + 1}) Reporting"

selection = 0

while selection != counter
  puts "Make a selection: "
  selection = gets.chomp.to_i
  if selection == counter
    break
  end
  id = ("id_" + selection.to_s).to_sym
  puts "How many?"
  quantity = gets.chomp.to_i
  subtotal ||= 0.0
  subtotal += (quantity * products[id][:retail_price].to_f)
  puts subtotal

end






