import math
import readline

fn main() {
    mut reader := readline.Readline {}
    mut result := []int{}
    for {
        line := reader.read_line('') or { break }
        if result.len == 0 {
            result = parse(line)
        } else {
            result = add(result, parse(line))
        }
    }
    println(magnitude(result))
}

fn parse(line string) []int {
    mut number := []int{cap: line.len}
    for chr in line {
        if chr == 91 {
            number << -1
        } else if chr >= 48 && chr < 58 {
            number << chr - 48
        }
    }
    return number
}

fn add(first []int, second []int) []int {
    mut number := []int{len: 1 + first.len + second.len}
    number[0] = -1
    for idx in 0..first.len {
        number[idx + 1] = first[idx]
    }
    for idx in 0..second.len {
        number[idx + 1 + first.len] = second[idx]
    }
    reduce(mut number)
    return number
}

fn reduce(mut number []int) {
    mut depth := 0
    mut stack := []int{cap: 5}
    for idx in 0..number.len {
        if number[idx] == -1 {
            depth += 1
            stack << 2
        } else if stack.len > 0 {
            stack[stack.len - 1] -= 1
            for stack[stack.len - 1] <= 0 {
                stack.delete_last()
                depth -= 1
                if stack.len == 0 {
                    break
                }
                stack[stack.len - 1] -= 1
            }
        }
        if depth == 5 {
            first := number[idx + 1]
            second := number[idx + 2]
            number[idx] = 0
            number.delete_many(idx + 1, 2)
            for i := idx - 1; i >= 0; i-= 1 {
                if number[i] != -1 {
                    number[i] += first
                    break
                }
            }
            for i in (idx + 1)..number.len {
                if number[i] != -1 {
                    number[i] += second
                    break
                }
            }
            reduce(mut number)
            return
        }
    }
    for idx in 0..number.len {
        if number[idx] != -1 && number[idx] >= 10 {
            value := number[idx]
            number.delete(idx)
            first := int(math.floor(f64(value)/2.0))
            second := int(math.ceil(f64(value)/2.0))
            do_insert(mut number, idx, [-1, first, second])
            reduce(mut number)
            return
        }
    }
}

fn magnitude(number []int) int {
    mut n := []int{len: number.len, init: number[it]}
    mut has_pair := true
    for has_pair {
        has_pair = false
        for idx in 0..n.len {
            if n[idx] == -1 {
                has_pair = true
                if n[idx + 1] != -1 && n[idx + 2] != -1 {
                    n[idx] = 3 * n[idx + 1] + 2 * n[idx + 2]
                    n.delete_many(idx + 1, 2)
                    continue
                }
            }
        }
    }
    return n[0]
}

// insert_many seems to be buggy in V at the moment
// so here is a custom implementation
fn do_insert(mut number []int, idx int, values []int) {
    number.grow_cap(values.len)
    for _ in 0..values.len {
        number << 0
    }
    for i := number.len - values.len - 1; i >= idx; i -= 1 {
        number[i + values.len] = number[i]
    }
    for i in 0..values.len {
        number[idx + i] = values[i]
    }
}
