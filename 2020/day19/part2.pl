#!/usr/bin/perl

my %rules = ();
my @messages = [];

while (<STDIN>) {
    chomp;
    if (/^(\d+)\s*:\s*(.*?)\s*$/) {
        $rules{$1} = $2
    } elsif ($_ ne "") {
        push @messages, $_
    }
}

sub expandRule {
    $_ = $_[0];
    if ($_ eq "") {
        return ""
    } elsif (/^\s*"(.*?)"\s*$/) {
        return $1
    } elsif (/^\s*([^|]+?)\s*[|]\s*([^|]+?)\s*$/) {
        my $x1 = $1;
        my $x2 = $2;
        return "(" . expandRule($x1) . "|" . expandRule($x2) . ")"
    } elsif (/^\s*(\d+)((\s+\d+)*)\s*$/) {
        my $x1i = $1;
        my $x1;
        my $x2 = $2;
        if ($x1i eq "8") {
            $x1 = "(" . expandRule("42") . ")+"
        } elsif ($x1i eq "11") {
            $x1 = "(";
            for (my $i = 1; $i <= 10; $i++) {
                if ($i != 1) {
                    $x1 .= "|"
                }
                $x1 .= ("(" . expandRule("42") . "){$i}" . "(" . expandRule("31") . "){$i}")
            }
            $x1 .= ")"
        } else {
            $x1 = expandRule($rules{$x1i});
        }
        return $x1 . expandRule($x2)
    } else {
        die "No match: " . $_
    }
}

my $pattern = '^' . expandRule("0") . '$';

print "$pattern\n";

my $count = 0;
foreach (@messages) {
    if (/$pattern/) {
        $count++
    }
}
print "$count\n";