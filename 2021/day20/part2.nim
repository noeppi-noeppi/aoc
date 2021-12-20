import std/sets

type Coords = tuple
    x: int
    y: int

var enhancement: string = readLine(stdin)
discard readLine(stdin)

var light: HashSet[Coords]

var line: string = readLine(stdin)
var currentY = 0
while line != "":
  var currentX = 0
  for chr in line:
    if chr == '#':
      light.incl((currentX, currentY))
    currentX += 1
  line = readLine(stdin)
  currentY += 1

var defaultVal: bool = false

proc is_light(x: int, y: int, minX: int, maxX: int, minY: int, maxY: int): int =
  if x >= minX and x <= maxX and y >= minY and y <= maxY:
    if light.contains((x, y)):
      return 1
    else:
      return 0
  else:
    if defaultVal:
      return 1
    else:
      return 0
      
proc check_mask(mask: int): bool =
  return enhancement[mask] == '#'

for _ in 1..50:
  var minX = 0
  var maxX = 0
  var minY = 0
  var maxY = 0
  for coords in light:
    minX = min(minX, coords.x)
    maxX = max(maxX, coords.x)
    minY = min(minY, coords.y)
    maxY = max(maxY, coords.y)
  var new_light: HashSet[Coords]
  for x in (minX - 1)..(maxX + 1):
    for y in (minY - 1)..(maxY + 1):
      var mask = (is_light(x - 1, y - 1, minX, maxX, minY, maxY) shl 8) or
        (is_light(x, y - 1, minX, maxX, minY, maxY) shl 7) or
        (is_light(x + 1, y - 1, minX, maxX, minY, maxY) shl 6) or
        (is_light(x - 1, y, minX, maxX, minY, maxY) shl 5) or
        (is_light(x, y, minX, maxX, minY, maxY) shl 4) or
        (is_light(x + 1, y, minX, maxX, minY, maxY) shl 3) or
        (is_light(x - 1, y + 1, minX, maxX, minY, maxY) shl 2) or
        (is_light(x, y + 1, minX, maxX, minY, maxY) shl 1) or
        is_light(x + 1, y + 1, minX, maxX, minY, maxY)
      if (check_mask(mask)):
        new_light.incl((x, y))
  light.clear()
  light.incl(new_light)
  if check_mask(0):
    defaultVal = not defaultVal
echo len(light)
