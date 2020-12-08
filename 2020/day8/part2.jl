instructions = String[]
global line = chomp(readline());
while line != ""
    global line
    push!(instructions, line)
    global line = chomp(readline());
end

instructions2 = copy(instructions)
for change in 1:length(instructions)

    global instructions = copy(instructions2)
    changeElems = split(instructions[change])
    changeOp = changeElems[1]
    changeAmount = changeElems[2]
    if changeOp == "nop"
        changeOp = "jmp"
    elseif changeOp == "jmp"
        changeOp = "nop"
    end
    global instructions[change] = changeOp * " " * changeAmount

    called = Int[]
    global inst = 0
    global accumulator = 0
    while !(inst in called) && inst < length(instructions)
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

    if inst >= length(instructions)
        println(accumulator)
    end

end