package main

import (
    "bufio"
    "fmt"
    "os"
    "strconv"
    "strings"
)

func main() {
    reader := bufio.NewReader(os.Stdin)
    _, _ = reader.ReadString('\n')

    line, _ := reader.ReadString('\n')
    var idStrs = strings.Split(line, ",")
    var ids = make([]int, len(idStrs))
    for idx, idStr := range idStrs {
        if idStr == "x" {
            ids[idx] = -1
        } else {
            ids[idx], _ = strconv.Atoi(strings.TrimSpace(idStr))
        }
    }

    minute := 0
    step := 1

    for idx, id := range ids {
        if id >= 0 {
            for (minute + idx) % id != 0 {
                minute += step
            }
            step = lcm(step, id)
        }
    }

    fmt.Println(minute)
}

func gcd(a int, b int) int {
    for b != 0 {
        t := b
        b = a % b
        a = t
    }
    return a
}

func lcm(a int, b int) int {
    return a * b / gcd(a, b)
}