@file:Suppress("PackageDirectoryMismatch")
package part2

fun main() {
    val input = readLine()!!.toCharArray().map { it.toString().toLong() }
    var max = input.maxOrNull()!!
    
    val map: MutableMap<Long, Long> = mutableMapOf()
    
    for (i in input.indices) {
        if (i + 1 < input.size) {
            map[input[i]] = input[i + 1]
        } else {
            map[input[i]] = max + 1
        }
    }
    while (map.size < 999999) {
        max += 1
        map[max] = max + 1
    }
    map[max + 1] = input[0]
    
    var current = input[0]
    repeat (10000000) {
        move(current, map)
        current = map[current]!!
    }
    
    val star1 = map[1]!!
    val star2 = map[star1]!!
    println(star1 * star2)
}

fun move(current: Long, map: MutableMap<Long, Long>) {
    val r1 = map[current]!!
    val r2 = map[r1]!!
    val r3 = map[r2]!!
    map[current] = map[r3]!!
    
    var dest = current - 1
    while (!map.containsKey(dest) || dest == r1 || dest == r2 || dest == r3) {
        dest -= 1
        if (dest <= 0) {
            dest = 1000000
        }
    }
    
    val afterDest = map[dest]!!
    map[dest] = r1
    map[r1] = r2
    map[r2] = r3
    map[r3] = afterDest
}