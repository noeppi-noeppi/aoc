#!/usr/bin/env perl6

class Seat {

    has Int $.row;
    has Int $.column;

    method id() {
        (self.row * 8) + self.column;
    }
}

sub parseSeat(Str $str) {
    my Int $row = 0;
    my Int $column = 0;

    for ^7 {
        if ($str.substr($_ .. $_) eq "B") {
            $row = $row +| (1 +< (6 - $_));
        }
    }

    for ^3 {
        if ($str.substr($_ + 7 .. $_ + 7) eq "R") {
            $column = $column +| (1 +< (2 - $_));
        }
    }

    return Seat.new(:$row, :$column);
}

sub MAIN() {
    my Int $max = 0;
    for lines() {
        chomp $_;
        $max = max($max, parseSeat($_).id);
    }
    say "Maximum Seat Id: $max";
}
