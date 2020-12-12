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

  static List rotate(Direction dir, int amount, int x, int z) {
    var newX = x;
    var newZ = z;
    var amountLeft = amount;
    var reverse = false;
    if (amountLeft < 0) {
      amountLeft = -amountLeft;
      reverse = true;
    }
    while (amountLeft > 0) {
      amountLeft -= 90;
      if (reverse) {
        var tmp = newZ;
        newZ = newX;
        newX = -tmp;
      } else {
        var tmp = newX;
        newX = newZ;
        newZ = -tmp;
      }
    }
    
    return [ newX, newZ ];
  }
}

void main() {
  var x = 0;
  var z = 0;
  var wx = 10;
  var wz = -1;
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
      wx += Direction.north.xd * value;
      wz += Direction.north.zd * value;
    } else if (line.startsWith('S')) {
      wx += Direction.south.xd * value;
      wz += Direction.south.zd * value;
    } else if (line.startsWith('E')) {
      wx += Direction.east.xd * value;
      wz += Direction.east.zd * value;
    } else if (line.startsWith('W')) {
      wx += Direction.west.xd * value;
      wz += Direction.west.zd * value;
    } else if (line.startsWith('F')) {
      x += wx * value;
      z += wz * value;
    } else if (line.startsWith('R')) {
      var list = Direction.rotate(d, -value, wx, wz);
      wx = list[0];
      wz = list[1];
    } else if (line.startsWith('L')) {
      var list = Direction.rotate(d, value, wx, wz);
      wx = list[0];
      wz = list[1];
    }
  }
  
  print(x.abs() + z.abs());
}
