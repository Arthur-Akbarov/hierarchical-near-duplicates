#!/usr/bin/perl
#
# ./getRepeatsCount.pl
#
# считывает номера строк границ повторов из файла lineNumbers
# вычитывает повторы из файла input в одну строку каждый
#
# выводит кол-во повторов
#

use 5.010;
use strict;
use warnings;
use feature qw(say);
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
require 'getDoubleRegexRepl.pl';
require 'readLineNumbers.pl';
require 'readRepeatsByLineNumbers.pl';

my ($lineNumbersFileName, $regex, $inputFileName) = @ARGV;
utf8::decode($lineNumbersFileName);
utf8::decode($regex);
utf8::decode($inputFileName);
# warn "\n";
# warn "$regex\n\n";

@_ = readLineNumbers($lineNumbersFileName);
my @repeats = readRepeatsByLineNumbers(@_, $inputFileName);

my @indexes;
my $first = 1;
foreach my $i (0 .. $#repeats) {
    push @indexes, $i + 1 if $repeats[$i] =~ /$regex/;
}

printf "[%d] = {%s}\n", scalar @indexes, join(",", @indexes);
