asBinaryNumber := [ :x | x inject: 0 into: [ :n :b | (n bitShift: 1) bitOr: b asString asNumber ] ].

lines := Array new: stdin nextLine asNumber + 1.
1 to: lines size do: [ :x | lines at: x put: (asBinaryNumber value: stdin nextLine) ].

bitCount := lines inject: 0 into: [ :n :b | n max: b highBit ].

countBitO := [ :id | [ :l | (l inject: 0 into: [ :n :b | n + ((b bitAt: id) * 2 - 1) ]) positive asCBooleanValue ] ].
countBitC := [ :id | [ :l | (l inject: 0 into: [ :n :b | n + ((b bitAt: id) * 2 - 1) ]) positive not asCBooleanValue ] ].

bitList := Array new: bitCount.
1 to: bitCount do: [ :x | bitList at: x put: x ].

selector := [ :s | (bitList inject: lines into: [ :l :bit | l size == 1 ifTrue: [ l ] ifFalse: [ l select: [ :n | (n bitAt: (bitCount - bit + 1)) == ((s value: (bitCount - bit + 1)) value: l) ] ] ]) at: 1 ].

oxygen := selector value: countBitO.
co2 := selector value: countBitC.

(oxygen * co2) printNl.
