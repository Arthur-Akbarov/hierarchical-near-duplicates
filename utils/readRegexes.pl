use 5.010;
use strict;
use warnings;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

sub readRegexes {
    my $regexFileName = shift;
    my @regexes;

    open(my $fh, '<:encoding(UTF-8)', $regexFileName) or die "Could not open file '$regexFileName' $!";
    while (<$fh>) {
        # next if ! /\S/;
        next if /^#/;
        push @regexes, $_;
    }
    close($fh) or warn "Unable to close file '$regexFileName': $!";

    s/\r?\n$// for @regexes;

    # warn "regexes[$_]\n$regexes[$_]\n\n" for (0 .. $#regexes);

    return @regexes;
}
