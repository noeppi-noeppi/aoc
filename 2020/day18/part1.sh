#!/usr/bin/env bash

rcfile=`mktemp`
cat > "$rcfile" << EOF
def op additive false * (x, y) = x * y
EOF

echo "0 `perl -ne 'chomp;print " + ($_)"' -`" | java -Dtuxtr.rcfile=$rcfile -jar TuxCalculator.jar nogui

rm "$rcfile"