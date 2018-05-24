#!/usr/bin/perl
#
# used by tree.pl
# ./testHighlightRegex.pl
#

use 5.010;
use strict;
use warnings;
binmode(STDOUT, ":utf8");
require 'getDoubleRegexRepl.pl';

my $parentRegex = 'ab?c\??d\.(e)?(f|g)h.*?i[\s\S]*?j';
my $regex = 'zac\?d\.(e)?fh.*?k.*?i[\s\S]*?l?.*?jm';

my $expectedRegexPattern = 'a(b\?|b?)c(\\\\\\?\?|\\\\\?|)d\\\\\.(\(e\)\?|e|)(\(f\|g\)|f|g)h(\.\*\?|.*?)i(\[\\\s\\\S\]\*\?|[\s\S]*?)j';
my $expectedRepl = q('{a}'.$1.'{c}'.$2.'{d\.}'.$3.'{}'.$4.'{h}'.$5.'{i}'.$6.'{j}');
my $expectedResult = q("[z{a}{c}\?{d\.}]".$1."[{}f{h}]".$2."[k]".$3."[{i}]".$4."[]".$5."[]".$6."[{j}m]");

print "expected repl = $expectedRepl\n";
my $result = getDoubleRegexRepl($parentRegex, $regex);
print "expected regexPattern = $expectedRegexPattern\n";

print "expected result = $expectedResult\n";
print "  actual result = $result\n";

