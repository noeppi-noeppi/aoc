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
        my $x1 = $rules{$1};
        my $x2 = $2;
        return expandRule($x1) . expandRule($x2)
    } else {
        die "No match: " . $_
    }
}

my $pattern = '^' . expandRule("0") . '$';

my $count = 0;
foreach (@messages) {
    if (/$pattern/) {
        $count++
    }
}
print "$count\n";