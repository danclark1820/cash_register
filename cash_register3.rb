require 'csv'
require 'pry'

products = {}
transactions = {}

def currency_conv(float)
  "$%0.2f" % float
end

#imports csv and puts into products hash
ctr = 1
CSV.foreach('products.csv', headers: true) do |row|
  products[('id_' + ctr.to_s).to_sym] = {
    sku: row[0],
    name: row[1],
    wholesale_price: row[2].to_f,
    retail_price: row[3].to_f
  }
  ctr += 1
end

#Creates Table
counter = 1
puts "Welcome to James' coffee emporium"
products.each do |key, value|
  puts "#{counter}) Add item - #{currency_conv(products[key][:retail_price])} - #{products[key][:name]}"
  counter += 1
end
puts "#{counter}) Complete Sale"
puts "#{counter + 1}) Reporting"

#Asks user for input then does math and stores transactions
selection = 0
while selection != counter
  puts "Make a selection: "
  selection = gets.chomp.to_i
  if selection == counter
    break
  end
  id = ("id_" + selection.to_s).to_sym
  puts "How many #{products[id][:name]}?"
  quantity = gets.chomp.to_i
  subtotal ||= 0.0
  subtotal += (quantity * products[id][:retail_price].to_f)
  if !(transactions[id] == nil)
    transactions[id] += quantity
  else
    transactions[id] = quantity
  end
  puts "Subtotal: #{currency_conv(subtotal)}"


end
#This writes quantity & sku to csv output
# We will add a date field to csv output when we finish eating
CSV.open('report.csv', "wb") do |row|
  transactions.each do |key, value|
    row << [
      products[key][:sku],
      products[key][:name],
      transactions[key],
      transactions[key] * products[key][:retail_price],
      (products[key][:retail_price]-products[key][:wholesale_price]) * transactions[key]
    ]
 end
end

#Creates Sale Complete
puts "===Sale Complete==="
puts ""
total = 0.0
transactions.each do |key, value|
  puts "$#{products[key][:retail_price] * transactions[key]} - #{transactions[key]} #{products[key][:name]} "
  total += products[key][:retail_price] * transactions[key]
end
puts "\nTotal: #{currency_conv(total)}"

#Get Tendered
puts "\nWhat is the amount tendered?"
tendered = gets.chomp.to_f

#Creates Receipt
puts "===Thank You!==="
puts "The total change due is #{currency_conv(tendered-total)}\n\n "
puts Time.now.strftime("%m/%d/%Y %I:%M%p")
puts "================"








