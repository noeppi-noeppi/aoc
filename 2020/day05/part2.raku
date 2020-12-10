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
    my Int @seats = [];
    for lines() {
        chomp $_;
        my Seat $seat = parseSeat($_);
        if ($seat.row != 0 && $seat.row != 127) {
            @seats.push(parseSeat($_).id);
        }
    }

    for ^1024 {
        #  && @seats.contains($_ - 1) && @seats.contains($_ + 1)
        if (!@seats.contains($_) && @seats.contains($_ - 1) && @seats.contains($_ + 1)) {
            say "Found Seat: $_";
            return
        }
    }
    say "No seat found."
}
