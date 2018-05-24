#!/usr/bin/perl
#
# ./bound.pl "string reside.re" > "string reside.ln"
#

use 5.010;
use strict;
use warnings;
use feature "say";
binmode(STDOUT, ":utf8");

my $input = slurp("input");
my $regex = readFirstLine($ARGV[0]);
# warn $regex;
my $count = 0;

# do not set /m parameter
while ($input =~ /$regex/g) {
    my $start = substr $input, 0, $-[0];
    my $end   = substr $input, 0, $+[0];

    my $startLineNumber = @{[ $start =~ /$/gm ]};
    my $endLineNumber   = @{[ $end =~ /$/gm ]};

    my $repeat = substr $input, $-[0], $+[0] - $-[0];

    $count++;
    say "$count=$startLineNumber-$endLineNumber=", ($endLineNumber - $startLineNumber + 1);
    # say "${repeat}\n";
}

# say "$count";

sub slurp {
    my $file = shift;
    local $/ = undef;
    open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file '$file' $!";
    my $content = <$fh>;
    close($fh) or warn "Unable to close file '$file': $!";
    return $content;
}

sub readFirstLine {
    my $file = shift;
    open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file '$file' $!";
    my $firstLine = <$fh>;
    close($fh) or warn "Unable to close file '$file': $!";
    return $firstLine;
}

