var INPUT = "";

var lines = INPUT.split("\n");
var sum = 0;
for line in lines {
  var mapPart = line[0 .. (line.indexOf('|') - 1)];
  var map = digitMap(mapPart);
  var outputPart = line[(line.indexOf('|') + 2) .. $];
  var result = 0;
  for resultDigit in outputPart.split(" ") {
    var digitValue = getDigit(map, resultDigit);
    result *= 10;
    result += digitValue;
  }
  sum += result;
}
println(sum);

function getDigit(map as string[], part as string) as int {
  var i = 0;
  while i <= 9 {
    if map[i].length == part.length {
      var test = true;
      for chr in map[i] {
        if !(chr in part) {
          test = false;
        }
      }
      if (test) {
        return i;
      }
    }
    i += 1;
  }
  println("Could not determine digit for " + part);
  return 0;
}

function digitMap(defs as string) as string[] {
  var parts = defs.split(" ");
  var mapping = [ "", "", "", "", "", "", "", "", "", "" ];
  for part in parts {
    if part.length == 2 {
      mapping[1] = part;
    } else if part.length == 4 {
      mapping[4] = part;
    } else if part.length == 3 {
      mapping[7] = part;
    } else if part.length == 7 {
      mapping[8] = part;
    }
  }
  for part in parts {
    if (part.length == 5) {
      if (mapping[1][0] in part && mapping[1][1] in part) {
        mapping[3] = part;
      }
    } else if (part.length == 6) {
      if (mapping[1][0] in part && mapping[1][1] in part) {
        if (mapping[4][0] in part && mapping[4][1] in part && mapping[4][2] in part && mapping[4][3] in part) {
          mapping[9] = part;
        } else {
          mapping[0] = part;
        }
      } else {
        mapping[6] = part;
      }
    }
  }
  for part in parts {
    if (part.length == 5) {
      if (part[0] in mapping[6] && part[1] in mapping[6] && part[2] in mapping[6] && part[3] in mapping[6] && part[4] in mapping[6]) {
        mapping[5] = part;
      } else if !(mapping[1][0] in part && mapping[1][1] in part) {
        mapping[2] = part;
      }
    }
  }
  return mapping;
}
