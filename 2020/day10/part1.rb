adapters = []
line = gets.chomp
until line == nil || line.empty?
  adapters << line.to_i
  line = gets.chomp
end

unless adapters.include?(0)
  adapters << 0
end
adapters << adapters.max + 3
adapters = adapters.sort

one = 0
three = 0
for i in 1 .. adapters.size - 1
  diff = adapters[i] - adapters[i - 1]
  if diff == 1
    one += 1
  elsif diff == 3
    three += 1
  end
end

puts one * three