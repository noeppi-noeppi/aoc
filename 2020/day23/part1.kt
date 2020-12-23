@file:Suppress("PackageDirectoryMismatch")
package part1

fun main() {
    var current = 0
    var input = readLine()!!.toCharArray().map { it.toString().toInt() }.toMutableList()
    repeat (100) {
        val newInput = input.subList(current, input.size).toMutableList()
        newInput.addAll(input.subList(0, current))
        input = newInput
        val currentLabel = input[0]
        move(input)
        current = input.indexOf(currentLabel)
        current = (current + 1) % input.size
    }
    for (i in input.indexOf(1) + 1 until input.indexOf(1) + input.size) {
        print(input[i % input.size])
    }
    println()
}

fun move(input: MutableList<Int>) {
    var destV = input[0] - 1
    val r1 = input.removeAt(1)
    val r2 = input.removeAt(1)
    val r3 = input.removeAt(1)
    
    var dest = -1
    while (dest < 0) {
        dest = input.indexOf(destV)
        destV -= 1
        if (destV < 1) {
            destV = input.maxOrNull()!!
        }
    }
    
    input.add(dest + 1, r3)
    input.add(dest + 1, r2)
    input.add(dest + 1, r1)
}