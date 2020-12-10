adapters = []
line = gets.chomp
until line == nil || line.empty?
  adapters << line.to_i
  line = gets.chomp
end

unless adapters.include?(0)
  adapters << 0
end
target = adapters.max + 3
adapters << target
adapters = adapters.sort

possibilities = { 0 => 1 }

adapters.each do |adapter|
  if adapter > 0
    count = 0

    if adapters.include?(adapter - 1)
      count += possibilities[adapter - 1]
    end

    if adapters.include?(adapter - 2)
      count += possibilities[adapter - 2]
    end

    if adapters.include?(adapter - 3)
      count += possibilities[adapter - 3]
    end

    possibilities[adapter] = count
  end
end

puts possibilities[target]