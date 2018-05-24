#!/usr/bin/perl
#
# ./bound.pl
#

use 5.010;
use strict;
use warnings;
use feature "say";
binmode(STDOUT, ":utf8");

my $input = slurp("input");
my $count = 0;
my $fullCount = 0;

# my $regex = 'Removes the listener from the collection of listeners (who|that) will be notified when';
my $regex = 'the collection of polygons the receiver maintains to describe its area\.';
# my $regex = '^Parameters:\r?$';
$regex = '\r?\n\r?\n\K((?!\r?\n\r?\n)[\s\S])*?' . $regex . '[\s\S]*?(?=\r?\n\r?\n)';

while ($input =~ /$regex/gm) {
    $fullCount++;

    my $start = substr $input, 0, $-[0];
    my $end   = substr $input, 0, $+[0];

    my $startLineNumber = @{[ $start =~ /$/gm ]};
    my $endLineNumber   = @{[ $end =~ /$/gm ]};

    my $repeat = substr $input, $-[0], $+[0] - $-[0];

    if ($repeat =~ /^(Parameters:|Throws:|See Also:)\r?$/m) {
        $count++;
        say "$count=$startLineNumber-$endLineNumber=", ($endLineNumber - $startLineNumber + 1);
        # say "${repeat}\n";
    }
}

# say "$count";
# say "$fullCount";

sub slurp {
    my $file = shift;
    local $/ = undef;
    open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file '$file' $!";
    my $content = <$fh>;
    close($fh) or warn "Unable to close file '$file': $!";
    return $content;
}
