#!/usr/bin/perl
#
# ./highlightTwoRegex.pl
# ./highlightTwoRegex.pl | grep -P "START | END|$" --color
#
# считывает архетипы из файла archetypes
# считывает номера строк границ повторов из файла lineNumbers
# вычитывает повторы из файла input в одну строку каждый
#
# выводит все повторы с подсвеченными 1 и 2 архетипом
#

use 5.010;
use strict;
use warnings;
binmode(STDOUT, ":utf8");

@_ = readLineNumbers();
my @repeats = readRepeats(@_);
my @regexes = readRegexes();

foreach my $i (1 .. 1) {
    $repeats[$i] =~ /$regexes[0]/g;
    my @parentStarts = @-;
    my @parentEnds = @+;

    $repeats[$i] =~ /$regexes[1]/g;
    my @childStarts = @-;
    my @childEnds = @+;

    my $repeat = $repeats[$i];
    # print "$repeat\n";

    my $childLeft  = "[";
    my $childRight = "]";

    my $parentLeft  = "{";
    my $parentRight = "}";

    # my $left = "\x1b[94m";
    # my $right = "\x1b[0m";

    substr($repeat, $childEnds[0], 0) = $childRight;
    my $j = $#childEnds;

    for (my $i = $#parentStarts; $i >= 0; $i--) {
        while($parentEnds[$i] <= $childStarts[$j]) {
            substr($repeat, $childStarts[$j], 0) = $childRight;
            substr($repeat, $childEnds[$j], 0) = $childLeft;
            $j--;
        }

        substr($repeat, $parentEnds[$i], 0) = $parentLeft;
        substr($repeat, $parentStarts[$i], 0) = $parentRight;
    }

    substr($repeat, $childStarts[$j--], 0) = $childRight;

    for (my $i = $j; $i > 0; $i--) {
        substr($repeat, $childEnds[$i], 0) = $childLeft;
        substr($repeat, $childStarts[$i], 0) = $childRight;
    }

    substr($repeat, $childStarts[0], 0) = $childLeft;

    print "$repeat\n";
}

# for (my $i = 1; $i <= 30; $i++) {
    # $repl =~ /(^|[^\\])(\\\\)*\K\([^)]*\)/g;
    # print join(", ", @-);
    # print join(", ", @+);
    # push @{$left{$_}}, $-[0];
    # push @{$right{$_}}, $+[0];
# }

# $repl = '"' . $left . $repl . $right . '"';
# $repl =~ s/\\(.)/$1/g;

# for my $j (0 .. $#repeats) {
#     my $repeat = $repeats[$j] =~ s/$regexes[0]/$repl/eer;
#     print "$repeat\n\n";
# }

# while ($regex =~ /(^|[^\\])(\\\\)*\K\([^)]*\)/g) {

sub getPoints {
    my $regex = shift;
    my $repeat = shift;

    $regex =~ s/\[\\s\\S\]\*\?|\.\*\?/($&)/g;


    # print join(", ", @-) . "\n";
    # print join(", ", @+) . "\n";

    return (\@-, \@+);
}

sub readLineNumbers {
    my (@start, @end);
    my $pattern = '(\d+)-(\d+)';

    my $lineNumbersFileName = "lineNumbers";
    open(my $fh, '<:encoding(UTF-8)', $lineNumbersFileName) or die "Could not open file '$lineNumbersFileName' $!";
    my $str = <$fh>;
    close($fh) or warn "Unable to close file '$lineNumbersFileName': $!";

    while ($str =~ /$pattern/g) {
        push @start, $1;
        push @end, $2;
        # print "$1-$2\n";
    }

    return (\@start, \@end);
}

sub readRepeats {
    my (@start, @end);
    push @start, 0, @{$_[0]};
    push @end, 0, @{$_[1]};

    my @repeat;
    my $inputFileName = "input";

    open(my $fh, '<:encoding(UTF-8)', $inputFileName) or die "Could not open file '$inputFileName' $!";
    foreach my $i (1 .. $#start) {
        foreach my $j (1 .. $start[$i] - $end[$i - 1] - 1) {
            my $devnull = <$fh>;
        }
        foreach my $j (1 .. $end[$i] - $start[$i] + 1) {
            $repeat[$i - 1] .= <$fh>;
        }
    }
    close($fh) or warn "Unable to close file '$inputFileName': $!";

    s/\r?\n$//g for @repeat;

    # foreach my $i (0 .. $#repeat) {
    #     print "START repeat[$i]\n" . $repeat[$i] . "\n\n";
    # }

    return @repeat;
}

sub readRegexes {
    my $regexFileName = "archetypes";
    my @regexes;
    open(my $fh, '<:encoding(UTF-8)', $regexFileName) or die "Could not open file '$regexFileName' $!";
    while (<$fh>) {
        next if ! /\S/;
        next if /^#/;
        push @regexes, $_;
    }
    close($fh) or warn "Unable to close file '$regexFileName': $!";

    s/\r?\n$//g for @regexes;
    s/\[\\s\\S\]\*\?|\.\*\?/($&)/g for @regexes;

    # foreach my $i (0 .. $#regexes) {
    #     print "START regexes[$i]\n" . $regexes[$i] . "\n\n";
    # }

    return @regexes;
}
