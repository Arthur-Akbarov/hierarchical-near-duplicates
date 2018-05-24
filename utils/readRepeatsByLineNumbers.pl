use 5.010;
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

sub readRepeatsByLineNumbers {
    my (@start, @end);
    push @start, 0, @{$_[0]};
    push @end, 0, @{$_[1]};

    my $inputFileName = $_[2] //= "input";
    my @repeats;

    open(my $fh, '<:encoding(UTF-8)', $inputFileName) or die "Could not open file '$inputFileName' $!";
    foreach my $i (1 .. $#start) {
        <$fh> for (1 .. $start[$i] - $end[$i - 1] - 1);
        $repeats[$i - 1] .= <$fh> for (1 .. $end[$i] - $start[$i] + 1);
    }
    close($fh) or warn "Unable to close file '$inputFileName': $!";

    s/\r?\n$// for @repeats;

    # warn "repeats[$_]\n$repeats[$_]\n\n" for (0 .. $#repeats);

    return @repeats;
}
