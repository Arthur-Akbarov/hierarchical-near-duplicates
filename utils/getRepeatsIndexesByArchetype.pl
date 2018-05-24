#!/usr/bin/perl
#
# ./getRepeatsIndexesByArchetype.pl
# ./getRepeatsIndexesByArchetype.pl "debug functions"
# ./getRepeatsIndexesByArchetype.pl lineNumbersFileName regexesFileName
#
# считывает regexes из файла "$ARGV[0].re"
# считывает номера строк границ повторов из файла "$ARGV[0].ln"
# вычитывает повторы из файла input в одну строку каждый
#
# для каждого архетипа пишет в строку номера повторов его содержащих
#

use 5.010;
use strict;
use warnings;
use feature 'say';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';
require 'readLineNumbers.pl';
require 'readRepeatsByLineNumbers.pl';

my $length = @ARGV;
my ($lineNumbersFileName, $regexesFileName);

if ($length == 0) {
    die "Missed arguments: lineNumbersFileName and regexesFileName, or title";
} elsif ($length == 1) {
    $lineNumbersFileName = "$ARGV[0].ln";
    $regexesFileName = "$ARGV[0].re";
} else {
    $lineNumbersFileName = $ARGV[0];
    $regexesFileName = $ARGV[1];
}

@_ = readLineNumbers($lineNumbersFileName);
my @repeats = readRepeatsByLineNumbers(@_);
my @regexes = readRegexes($regexesFileName);

for my $i (0 .. $#regexes) {
    my @array;

    for my $j (0 .. $#repeats) {
        # push @array, $j+1 if $repeats[$j] =~ /$regexes[$i]/;
        push @array, ($repeats[$j] =~ /$regexes[$i]/) ? $j+1 : " ";
    }

    say join("", @array) . "  " . substr($regexes[$i], 0, 50);
}

sub readRegexes {
    my $regexesFileName = shift;
    my (@regexes, @regexLines);

    open(my $fh, '<:encoding(UTF-8)', $regexesFileName) or die "Could not open file '$regexesFileName' $!";
    my $i = 0;
    while (<$fh>) {
        $i++;
        next if ! /\S/ or /^#/;
        push @regexes, $_;
        push @regexLines, $i;
    }
    close($fh) or warn "Unable to close file '$regexesFileName': $!";

    s/\r?\n$// for @regexes;

    # warn "regexes[$_]\n$regexes[$_]\n\n" for (0 .. $#regexes);

    return @regexes;
}
