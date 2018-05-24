#!/usr/bin/perl
#
# ./highlightRepeats.pl
# ./highlightRepeats.pl | grep -P "[][{}]|$" --color
#
# считывает номера строк границ повторов из файла lineNumbers
# вычитывает повторы из файла input в одну строку каждый
#
# выводит первой строкой все matches
# далее все повторы с подсвеченными $regex и $archetype,
# упредив каждый номером/индексом повтора
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

my ($lineNumbersFileName, $regex, $archetype, $inputFileName) = @ARGV;
utf8::decode($lineNumbersFileName);
utf8::decode($regex);
utf8::decode($archetype);
utf8::decode($inputFileName);
# warn "\n";
# warn "$regex\n\n";
# warn "$archetype\n\n";

@_ = readLineNumbers($lineNumbersFileName);
my @start = @{$_[0]};
my @repeats = readRepeatsByLineNumbers(@_, $inputFileName);

my $repl = getDoubleRegexRepl($regex, $archetype);
# warn "repl2 = $repl\n\n";

# warn "archetype = $archetype\n";
$archetype =~ s/(\G|[^\\])(\\\\)*\K\(([^)]*)\)\?/($3|)/g;
$archetype =~ s/(\G|[^\\])(\\\\)*\K[^][\\.?*|()][+*?]/($&)/g;
$archetype =~ s/(\G|[^\\])(\\\\)*\K\\[][\\.?*|()][+*?]/($&)/g;
$archetype =~ s/(\G|[^\\])(\\\\)*\K\\[wd]([+*?](\?)?)?/($&)/g;
$archetype =~ s/(\G|[^\\])(\\\\)*\K\.\*\?/($&)/g;
$archetype =~ s/(\G|[^\\])(\\\\)*\K\[\\s\\S\]\*\?/($&)/g;
# warn "archetype = $archetype\n\n";

my ($response, @indexes);
my $first = 1;
foreach my $i (0 .. $#repeats) {
    next if ($regex ne "" && $repeats[$i] !~ /$regex/);
    next unless $repeats[$i] =~ s/$archetype/$repl/ee;

    push @indexes, $i + 1;

    my $j = $start[$i];
    # $repeats[$i] =~ s/[^\r\n]+?(\r?\n|$)/$j++."-$&"/eg;
    $repeats[$i] =~ s/(^|\r?\n)/"$&".$j++."-"/eg;

    ($first == 1) ? ($first = 0) : ($response .= "\n");

    $response .= $i + 1 . "\n$repeats[$i]";
}

printf "[%d] = {%s}\n", scalar @indexes, join(",", @indexes);
print $response;
