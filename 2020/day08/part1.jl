instructions = String[]
global line = chomp(readline());
while line != ""
    global line
    push!(instructions, line)
    global line = chomp(readline());
end

called = Int[]
global inst = 0
global accumulator = 0
while !(inst in called)
    push!(called, inst)
    elems = split(instructions[inst + 1])
    op = elems[1]
    amount = parse(Int, elems[2])
    if op == "acc"
        global accumulator += amount
    end

    if op == "jmp"
        global inst += amount
    else
        global inst += 1
    end
end

println(accumulator)