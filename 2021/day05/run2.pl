#!/usr/bin/perl

use strict;
use warnings;

open(FILE, ">part2-generated.pro") || die;
while (<STDIN>) { print FILE "line([$1,$2],[$3,$4]).\n" if (/(\d+),(\d+) -> (\d+),(\d+)/) }
open(IN, "<part2.pro") || die;
while (<IN>) { print FILE $_ }
close(IN);
close(FILE);
exec("sh -c 'echo \"solve(R).\" | prolog -s part2-generated.pro'");
