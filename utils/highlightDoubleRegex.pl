#!/usr/bin/perl
#
# ./highlightDoubleRegex.pl
# ./highlightDoubleRegex.pl | grep -P "[][{}]|$" --color
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
use feature qw(say);
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
require 'getDoubleRegexRepl.pl';

@_ = readLineNumbers();
my @repeats = readRepeats(@_);
my @regexes = readRegexes();

my $repl = getDoubleRegexRepl($regexes[0], $regexes[1]);
# warn "$repl\n\n";

my $regex = $regexes[1];

# warn "$regex\n\n";
$regex =~ s/(\G|[^\\])(\\\\)*\K\([^)]*\)\??/($&)/g;
$regex =~ s/(\G|[^\\])(\\\\)*\K[^][\\.?*|()][+*?]/($&)/g;
$regex =~ s/(\G|[^\\])(\\\\)*\K\\[][\\.?*|()][+*?]/($&)/g;
$regex =~ s/(\G|[^\\])(\\\\)*\K\.\*\?/($&)/g;
$regex =~ s/(\G|[^\\])(\\\\)*\K\[\\s\\S\]\*\?/($&)/g;

foreach my $i (0 .. $#repeats) {
    $repeats[$i] =~ s/$regex/$repl/ee;
    say "$repeats[$i]\n";
}

sub readLineNumbers {
    my (@start, @end);
    my $pattern = '(\d+)-(\d+)';

    my $lines;
    {
        open(my $fh, '<:encoding(UTF-8)', $lineNumbersFileName) or die "Could not open file '$lineNumbersFileName' $!";
        local $/ = undef;
        $lines = <$fh>;
        close($fh) or warn "Unable to close file '$lineNumbersFileName': $!";
    }

    while ($lines =~ /$pattern/g) {
        push @start, $1;
        push @end, $2;
        # warn "$1-$2\n";
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
        <$fh> for (1 .. $start[$i] - $end[$i - 1] - 1);
        $repeat[$i - 1] .= <$fh> for (1 .. $end[$i] - $start[$i] + 1);
    }
    close($fh) or warn "Unable to close file '$inputFileName': $!";

    s/\r?\n$// for @repeat;

    # foreach my $i (0 .. $#repeat) {
    #     warn "START repeat[$i]\n$repeat[$i]\n\n";
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

    s/\r?\n$// for @regexes;

    # foreach my $i (0 .. $#regexes) {
    #     warn "START regexes[$i]\n$regexes[$i]\n\n";
    # }

    return @regexes;
}
