require 'csv'
require 'pry'

def currency_conv(float)
  "$%0.2f" % float
end

def file_to_hash(filename)
  #imports csv and puts into products hash
  hash = {}
  ctr = 1
  CSV.foreach(filename, headers: true) do |row|
    hash[('id_' + ctr.to_s).to_sym] = {
      sku: row[0],
      name: row[1],
      wholesale_price: row[2].to_f,
      retail_price: row[3].to_f
    }
    ctr += 1
  end
  hash
end

def create_report_file(filename, hash, transactions)
  #This writes quantity & sku to csv output
  #We will add a date field to csv output when we finish eating
  CSV.open(filename, "ab") do |row|
    transactions.each do |key, value|
      row << [
        hash[key][:sku],
        hash[key][:name],
        transactions[key],
        transactions[key] * hash[key][:retail_price],
        (hash[key][:retail_price]-hash[key][:wholesale_price]) * transactions[key],
        Time.now.strftime("%m/%d/%Y")
      ]
   end
  end
end

def manager_report(filename, user_date)
  report_hash = {}
  CSV.foreach('report.csv', 'r') do |row|
    if row.include?(user_date)
      if report_hash.include?(row[0])
        report_hash[row[0]][:quantity] += row[2].to_i
        report_hash[row[0]][:revenue] += row[3].to_i
        report_hash[row[0]][:profit] += row[4].to_i
      else
        report_hash[row[0]] = {
          name: row[1],
          quantity: row[2].to_i,
          revenue: row[3].to_f,
          profit: row[4].to_f
        }
      end
    end
  end
  report_hash
end

products = file_to_hash('products.csv')
transactions = {}




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
while selection < counter
  puts "Make a selection: "
  selection = gets.chomp.to_i
  if selection >= counter
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

#report generation was here
create_report_file('report.csv', products, transactions)

if selection == counter
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
elsif selection == counter + 1
  #Creates Report
  puts "What date would you like reports for? (MM/DD/YYYY)"
  user_date = gets.chomp
  until user_date.match(/(0[1-9]|1[012])[ \/.](0[1-9]|[12][0-9]|3[01])[ \/.](19|20)\d\d/)
    puts "Invalid date, please format date"
    user_date == gets.chomp
  end
  puts "On #{user_date} we sold:"
  profit = 0.0
  sales = 0.0
  manager_report('report.csv', user_date).each do |key, value|
    puts "SKU # #{key}, Name: #{value[:name]}, Quantity: #{value[:quantity]}, Revenue: #{currency_conv(value[:revenue])}, Profit: #{currency_conv(value[:profit])}"
    profit += value[:profit]
    sales += value[:revenue]
  end
  puts "Total Sales: #{currency_conv(sales)}"
  puts "Total Profit: #{currency_conv(profit)}"
end






