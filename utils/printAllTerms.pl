#!/usr/bin/perl
#
# ./printAllTerms.pl fileName
#
#

use 5.010;
use strict;
use warnings;
use feature "say";
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");


my $fileName = shift;
my $termPattern = '(?<edge>[^\w\s]*)\b(?:e\.?g\.|i\.?e\.|etc\.|\.\.[\.\/]|!=|[.!?](?!(?: |[^\w\s]+ [^\w\s]*(?-i:[A-Z])))|[^\n.!?])+\b(?&edge)';
my @repeats = readRepeats($fileName);
my @array;

foreach my $i (0 .. $#repeats) {
    push @array, $& while $repeats[$i] =~ /$termPattern/ig;
}

@array = sort @array;
say join("\n", @array);

sub readRepeats {
    my $fileName = shift;
    my @repeat;
    my $i = 0;

    open(my $fh, '<:encoding(UTF-8)', $fileName) or die "Could not open file '$fileName' $!";
    while (my $row = <$fh>) {
        if ($row !~ /^\r?\n$/) {
            $repeat[$i] .= $row;
        } else {
            $i++;
        }
    }
    close($fh) or warn "Unable to close file '$fileName': $!";

    s/\r?\n$// for @repeat;

    # warn "repeats[$_]\n$repeats[$_]\n\n" for (0 .. $#repeats);

    return @repeat;
}
