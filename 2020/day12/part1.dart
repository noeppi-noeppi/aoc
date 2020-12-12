import 'dart:convert';
import 'dart:io';

class Direction {
  final value;
  final xd;
  final zd;

  const Direction._internal(this.value, this.xd, this.zd);

  toString() => 'Direction.$value';

  static const north = const Direction._internal('NORTH', 0, -1);
  static const south = const Direction._internal('SOUTH', 0, 1);
  static const east = const Direction._internal('EAST', 1, 0);
  static const west = const Direction._internal('WEST', -1, 0);

  static Direction opposite(Direction dir) {
    switch (dir) {
      case north:
        return south;
      case south:
        return north;
      case east:
        return west;
      case west:
        return east;
    }
  }

  static Direction rotate(Direction dir, int amount) {
    var newDir = dir;
    var amountLeft = amount;
    var reverse = false;
    if (amountLeft < 0) {
      amountLeft = -amountLeft;
      reverse = true;
    }
    while (amountLeft > 0) {
      amountLeft -= 90;
      switch (newDir) {
        case north: {
            newDir = reverse ? east : west;
          }
          break;
        case south: {
            newDir = reverse ? west : east;
          }
          break;
        case east: {
            newDir = reverse ? south : north;
          }
          break;
        case west: {
            newDir = reverse ? north : south;
          }
          break;
      }
    }
    
    return newDir;
  }
}

void main() {
  var x = 0;
  var z = 0;
  var d = Direction.east;

  while (true) {
    var line = stdin
        .readLineSync(encoding: Encoding.getByName('utf-8'))
        .trim()
        .replaceAll(' ', '')
        .toUpperCase();
    if (line == '') {
      break;
    }
    var value = int.parse(line.substring(1));
    if (line.startsWith('N')) {
      x += Direction.north.xd * value;
      z += Direction.north.zd * value;
    } else if (line.startsWith('S')) {
      x += Direction.south.xd * value;
      z += Direction.south.zd * value;
    } else if (line.startsWith('E')) {
      x += Direction.east.xd * value;
      z += Direction.east.zd * value;
    } else if (line.startsWith('W')) {
      x += Direction.west.xd * value;
      z += Direction.west.zd * value;
    } else if (line.startsWith('F')) {
      x += d.xd * value;
      z += d.zd * value;
    } else if (line.startsWith('R')) {
      d = Direction.rotate(d, -value);
    } else if (line.startsWith('L')) {
      d = Direction.rotate(d, value);
    }
  }

  print(x.abs() + z.abs());
}
