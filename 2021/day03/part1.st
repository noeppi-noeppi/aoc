asBinaryNumber := [ :x | x inject: 0 into: [ :n :b | (n bitShift: 1) bitOr: b asString asNumber ] ].

lines := Array new: stdin nextLine asNumber + 1.
1 to: lines size do: [ :x | lines at: x put: (asBinaryNumber value: stdin nextLine) ].

countBit := [ :id | (lines inject: 0 into: [ :n :b | n + ((b bitAt: id) * 2 - 1) ]) positive ].

bits := Array new: (lines inject: 0 into: [ :n :b | n max: b highBit ]).
1 to: bits size do: [ :x | bits at: x put: (countBit value: bits size - x + 1) ].

gamma := bits inject: 0 into: [ :n :b | (n bitShift: 1) bitOr: b asCBooleanValue ].
epsilon := bits inject: 0 into: [ :n :b | (n bitShift: 1) bitOr: b not asCBooleanValue ].

(gamma * epsilon) printNl.
