var INPUT = "";

var lines = INPUT.split("\n");
var sum = 0;
for line in lines {
  var outputPart = line[(line.indexOf('|') + 2) .. $];
  for resultDigit in outputPart.split(" ") {
    if (resultDigit.length == 2 || resultDigit.length == 3 || resultDigit.length == 4 || resultDigit.length == 7) {
      sum += 1;
    }
  }
}
println(sum);
