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
    top = find_border((coords[0], coords[1] + 1), 'bottom', elems, borders)
    bottom = find_border((coords[0], coords[1] - 1), 'top', elems, borders)
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

print(elems[(minx, miny)][0] * elems[(minx, maxy)][0] * elems[(maxx, miny)][0] * elems[(maxx,maxy)][0])