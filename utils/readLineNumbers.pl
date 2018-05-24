use 5.010;
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

sub readLineNumbers {
    my $lineNumbersFileName = shift;

    my $lines;
    {
        open(my $fh, '<:encoding(UTF-8)', $lineNumbersFileName) or die "Could not open file '$lineNumbersFileName' $!";
        local $/ = undef;
        $lines = <$fh>;
        close($fh) or warn "Unable to close file '$lineNumbersFileName': $!";
    }

    my $pattern = '(\d+)-(\d+)';
    my (@start, @end);

    while ($lines =~ /$pattern/g) {
        push @start, $1;
        push @end, $2;
        # warn "$1-$2\n";
    }

    return (\@start, \@end);
}
