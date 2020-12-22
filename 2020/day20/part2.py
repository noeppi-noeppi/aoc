import sys
from math import sqrt
from typing import Dict, List, Tuple, Optional


def rotated(border: Dict[str, str]) -> Dict[str, str]:
    return {
        'bottom': border['right'][::-1],
        'top': border['left'][::-1],
        'left': border['bottom'],
        'right': border['top']
    }


def check_neighbour(x: int, y: int, elems: Dict[Tuple[int, int], Tuple[int, int]], neighbours: List[Tuple[int, int]],
                    extend_x: bool, extend_y: bool, minx: int, maxx: int, miny: int, maxy: int) -> bool:
    return (extend_x or (maxx >= x >= minx)) and (extend_y or (maxy >= y >= miny)) and not (x, y) in elems and not (x, y) in neighbours


def get_neighbours(elems: Dict[Tuple[int, int], Tuple[int, int]], side_length: int) -> List[Tuple[int, int]]:
    minx = 0
    maxx = 0
    miny = 0
    maxy = 0
    for coords in elems:
        maxx = max(maxx, coords[0])
        minx = min(minx, coords[0])
        maxy = max(maxy, coords[1])
        miny = min(miny, coords[1])
    neighbours: List[Tuple[int, int]] = []
    for coords in elems:
        if check_neighbour(coords[0] + 1, coords[1], elems, neighbours, (maxx - minx) < side_length, (maxy - miny) < side_length, minx, maxx, miny, maxy):
            neighbours.append((coords[0] + 1, coords[1]))
        if check_neighbour(coords[0] - 1, coords[1], elems, neighbours, (maxx - minx) < side_length, (maxy - miny) < side_length, minx, maxx, miny, maxy):
            neighbours.append((coords[0] - 1, coords[1]))
        if check_neighbour(coords[0], coords[1] + 1, elems, neighbours, (maxx - minx) < side_length, (maxy - miny) < side_length, minx, maxx, miny, maxy):
            neighbours.append((coords[0], coords[1] + 1))
        if check_neighbour(coords[0], coords[1] - 1, elems, neighbours, (maxx - minx) < side_length, (maxy - miny) < side_length, minx, maxx, miny, maxy):
            neighbours.append((coords[0], coords[1] - 1))
    return neighbours


def find_border(coords: Tuple[int, int], border_side: str, elems: Dict[Tuple[int, int], Tuple[int, int]], borders: Dict[int, List[Dict[str, str]]]) -> Optional[str]:
    if coords in elems:
        content = elems[coords]
        return borders[content[0]][content[1]][border_side]
    else:
        return None


def find_match(coords: Tuple[int, int], possible: List[int], elems: Dict[Tuple[int, int], Tuple[int, int]], borders: Dict[int, List[Dict[str, str]]]) -> Tuple[int, int]:
    top = find_border((coords[0], coords[1] - 1), 'bottom', elems, borders)
    bottom = find_border((coords[0], coords[1] + 1), 'top', elems, borders)
    left = find_border((coords[0] - 1, coords[1]), 'right', elems, borders)
    right = find_border((coords[0] + 1, coords[1]), 'left', elems, borders)
    found: List[Tuple[int, int]] = []
    for id in possible:
        for variantId, variant in enumerate(borders[id]):
            if (top is None or top == variant['top']) \
              and (bottom is None or bottom == variant['bottom']) \
              and (left is None or left == variant['left']) \
              and (right is None or right == variant['right']):
                found.append((id, variantId))
    if len(found) == 1:
        return found[0]
    else:
        return (-1, 0)


def vflip(tile: List[str]) -> List[str]:
    return tile[::-1]


def hflip(tile: List[str]) -> List[str]:
    new = []
    for row in tile:
        new.append(row[::-1])
    return new


def rotate(tile: List[str]) -> List[str]:
    new = []
    for x in range(0, len(tile)):
        row = ''
        for y in range(0, len(tile))[::-1]:
            row += tile[y][x]
        new.append(row)
    return new


def apply_transformations(tile: List[str], transform: int) -> List[str]:
    new = tile.copy()
    if (transform & (1 << 0)) != 0:
        new = vflip(new)
    if (transform & (1 << 1)) != 0:
        new = hflip(new)
    if (transform & (1 << 2)) != 0:
        new = rotate(new)
    return new


def crop(tile: List[str]) -> List[str]:
    new = []
    for x in range(1, len(tile) - 1):
        new.append(tile[x][1:-1])
    return new


def find_monsters(tile: List[str]) -> List[str]:
    #                 1111111111
    #       01234567890123456789
    #   +----------------------- 
    # 0 |                     # 
    # 1 |   #    ##    ##    ###
    # 2 |    #  #  #  #  #  #   

    for y in range(len(tile)):
        for x in range(len(tile[y])):
            if x + 19 < len(tile[y]) and y + 2 < len(tile):
                if tile[y][x + 18] in "#0" and tile[y + 1][x] in "#0" and tile[y + 1][x + 5] in "#0" \
                  and tile[y + 1][x + 6] in "#0" and tile[y + 1][x + 11] in "#0" and tile[y + 1][x + 12] in "#0" \
                  and tile[y + 1][x + 17] in "#0" and tile[y + 1][x + 18] in "#0" and tile[y + 1][x + 19] in "#0" \
                  and tile[y + 2][x + 1] in "#0" and tile[y + 2][x + 4] in "#0" and tile[y + 2][x + 7] in "#0" \
                  and tile[y + 2][x + 10] in "#0" and tile[y + 2][x + 13] in "#0" and tile[y + 2][x + 16] in "#0":
                    tile[y] = tile[y][:x + 18] + '0' + tile[y][x + 19:]
                    tile[y + 1] = tile[y + 1][:x] + '0' + tile[y + 1][x + 1:]
                    tile[y + 1] = tile[y + 1][:x + 5] + '0' + tile[y + 1][x + 6:]
                    tile[y + 1] = tile[y + 1][:x + 6] + '0' + tile[y + 1][x + 7:]
                    tile[y + 1] = tile[y + 1][:x + 11] + '0' + tile[y + 1][x + 12:]
                    tile[y + 1] = tile[y + 1][:x + 12] + '0' + tile[y + 1][x + 13:]
                    tile[y + 1] = tile[y + 1][:x + 17] + '0' + tile[y + 1][x + 18:]
                    tile[y + 1] = tile[y + 1][:x + 18] + '0' + tile[y + 1][x + 19:]
                    tile[y + 1] = tile[y + 1][:x + 19] + '0' + tile[y + 1][x + 20:]
                    tile[y + 2] = tile[y + 2][:x + 1] + '0' + tile[y + 2][x + 2:]
                    tile[y + 2] = tile[y + 2][:x + 4] + '0' + tile[y + 2][x + 5:]
                    tile[y + 2] = tile[y + 2][:x + 7] + '0' + tile[y + 2][x + 8:]
                    tile[y + 2] = tile[y + 2][:x + 10] + '0' + tile[y + 2][x + 11:]
                    tile[y + 2] = tile[y + 2][:x + 13] + '0' + tile[y + 2][x + 14:]
                    tile[y + 2] = tile[y + 2][:x + 16] + '0' + tile[y + 2][x + 17:]
    return tile

first_tile = -1
input: str = sys.stdin.read()
tiles: Dict[int, List[str]] = {}

for tile_str in input.split('\n\n'):
    if tile_str.strip() != '':
        lines = tile_str.strip().split('\n')
        id = int(lines[0].strip()[5:-1])
        if first_tile < 0:
            first_tile = id
        tiles[id] = lines[1:]

borders: Dict[int, List[Dict[str, str]]] = {}

for id in tiles:
    left: str = ''
    right: str = ''
    for line in tiles[id]:
        left += line[0]
        right += line[-1]

    base = {
        'top': tiles[id][0],
        'bottom': tiles[id][-1],
        'left': left,
        'right': right
    }

    flipped = [
        # normal
        base,

        # vflip
        {
            'bottom': base['top'],
            'top': base['bottom'],
            'left': base['left'][::-1],
            'right': base['right'][::-1]
        },

        # hflip
        {
            'bottom': base['bottom'][::-1],
            'top': base['top'][::-1],
            'left': base['right'],
            'right': base['left']
        },

        # vflip + hflip
        {
            'bottom': base['top'][::-1],
            'top': base['bottom'][::-1],
            'left': base['right'][::-1],
            'right': base['left'][::-1]
        }
    ]

    borders[id] = [
        flipped[0],
        flipped[1],
        flipped[2],
        flipped[3],
        rotated(flipped[0]),
        rotated(flipped[1]),
        rotated(flipped[2]),
        rotated(flipped[3])
    ]

elems: Dict[Tuple[int, int], Tuple[int, int]] = {
    (0, 0): (first_tile, 0)
}
side_length: int = int(sqrt(len(tiles)))
left: List[int] = list(tiles.keys()).copy()
left.remove(first_tile)

while len(left) > 0:
    neighbours = get_neighbours(elems, side_length)
    for coords in neighbours:
        value, rotation = find_match(coords, left, elems, borders)
        if value >= 0:
            left.remove(value)
            elems[coords] = (value, rotation)
            break

minx = 0
maxx = 0
miny = 0
maxy = 0
for coords in elems:
    maxx = max(maxx, coords[0])
    minx = min(minx, coords[0])
    maxy = max(maxy, coords[1])
    miny = min(miny, coords[1])

image: List[str] = []
off = 0
for y in range(miny, maxy + 1):
    for _ in range(0, 8):
        image.append('')

    for x in range(minx, maxx + 1):
        
        print(f"({x - minx},{y - miny}): {elems[(x, y)][0]} at {elems[(x, y)][1]}")
        
        data = crop(apply_transformations(tiles[elems[(x, y)][0]], elems[(x, y)][1]))
        for yd in range(0, 8):
            image[off + yd] += data[yd]
    off += 8

for line in image:
    print(line)

min_amount = side_length * side_length * 64
for i in range(0, 8):
    image_copy = apply_transformations(image.copy(), i)
    image_copy = find_monsters(image_copy)
    amount = 0
    for line in image_copy:
        amount += line.count('#')
    if (amount < min_amount):
        min_amount = amount

print(min_amount)