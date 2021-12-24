fs = require("fs")

arr_split = (arr, elem) ->
  na = []
  ca = []
  for e in arr
    if e == elem
      if ca.length > 0
        na.push(ca)
      ca = []
    else
      ca.push(e)
  if ca.length > 0
    na.push(ca)
  na

find_z = (group) ->
  zt = false
  xv = 0
  yv = 0
  last_line = ''
  for line in group
    if line == 'div z 26'
      zt = true
    else if line.startsWith('add x ') && line != 'add x z'
      xv = parseInt(line.substr(6))
    else if line.startsWith('add y ') && last_line == 'add y w'
      yv = parseInt(line.substr(6))
    last_line = line
  [zt, xv, yv]

base_mul = (z_maps, num, x, base) ->
  if (z_maps[num][x][1])
    26 * base
  else
    parseInt(base / 26) * 26

find = (z_maps, base, curr, num) ->
  if num == 14
    if base == 0
      return curr;
    else
      return -1
  else
    for x in [8..0]
      result = find(z_maps, base_mul(z_maps, num, x, base) + z_maps[num][x][0], (curr * 10) + x + 1, num + 1)
      if result >= 0
        return result
    return -1

groups = arr_split(fs.readFileSync(0).toString().split('\n').map((l) -> l.trim()).filter((l) -> l != ''), 'inp w')

z_map = groups.map(find_z)

ranges = {}
range_funcs = {}
stack = []

matching_range = (n) -> [1..9].filter((e) -> (e + n) >= 1 && (e + n) <= 9)

for i in [0..13]
  if !z_map[i][0]
    stack.unshift([i, z_map[i][2]])
  else
    do (i) ->
      res = stack.shift()
      dest = res[1] + z_map[i][1]
      ranges[String(res[0])] = matching_range(dest)
      range_funcs[String(i)] = [res[0], (w) -> w + dest ]

nums = []
for i in [0..13]
  if String(i) in Object.keys(ranges)
    nums.push(Math.max(...ranges[String(i)]))
  else
    nums.push(range_funcs[String(i)][1](nums[range_funcs[String(i)][0]]))

console.log nums.join('')
