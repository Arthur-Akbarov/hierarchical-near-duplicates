#!/usr/bin/perl
#
# ./highlightOneRegex.pl
# ./highlightOneRegex.pl | grep -P "START | END|$" --color
#
# считывает первый архетип из файла archetypes
# считывает номера строк границ повторов из файла lineNumbers
# вычитывает повторы из файла input в одну строку каждый
#
# выводит все повторы с подсвеченным архетипом
#

use 5.010;
use strict;
use warnings;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

@_ = readLineNumbers();
my @repeats = readRepeats(@_);
my @regexes = readRegexes();

$regexes[0] =~ s/\[\\s\\S\]\*\?|\.\*\?/($&)/g;

my $repl = $regexes[0] =~ s/&/\\&/gr;
$repl =~ s/\$$//;

# my $left = "[";
# my $right = "]";

my $left = "\x1b[94m";
my $right = "\x1b[0m";

for (my $i = 1; $i <= 30; $i++) {
    $repl =~ s/(^|[^\\])(\\\\)*\K\([^)]*\)/$right".\$$i."$left/;
}

$repl = '"' . $left . $repl . $right . '"';
$repl =~ s/\\(.)/$1/g;

for my $j (0 .. $#repeats) {
    my $repeat = $repeats[$j] =~ s/$regexes[0]/$repl/eer;
    print "$repeat\n\n";
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
        last;
    }
    close($fh) or warn "Unable to close file '$regexFileName': $!";

    s/\r?\n$//g for @regexes;

    # foreach my $i (0 .. $#regexes) {
    #     print "START regexes[$i]\n" . $regexes[$i] . "\n\n";
    # }

    return @regexes;
}
