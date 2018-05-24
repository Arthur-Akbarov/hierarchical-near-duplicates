use 5.010;
use strict;
use warnings;
use utf8;
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

sub getDoubleRegexRepl {
    my ($parentRegex, $regex) = @_;
    # warn "\n";
    # warn "$parentRegex\n\n";
    # warn "$regex\n\n";

    my $debug = 0;

    my $parentLeft  = ($debug == 1) ? "{" : "♠c♠";
    my $parentRight = ($debug == 1) ? "}" : "♥c♥";

    my $repl = convertToRepl($parentRegex, $parentLeft, $parentRight, "'");
    # warn "  actual repl = $repl\n";
    # warn "        repl = $repl\n";

    my $regexPattern = convertToRegexPattern($parentRegex);
    # warn "  actual regexPattern = $regexPattern\n";
    # warn "regexPattern = $regexPattern\n\n";

    my $result = $regex =~ s/$regexPattern/$repl/eer;
    # warn "$result\n";

    my $childLeft  = ($debug == 1) ? "[" : "♠h♠";
    my $childRight = ($debug == 1) ? "]" : "♥h♥";

    $result = convertToRepl($result, $childLeft, $childRight, '"');
    # warn "$result\n";

    return $result;
}

sub convertToRegexPattern {
    my $parentRegex = shift;

    $parentRegex =~ s/[][\\.?*+|(){}^\$]/\\$&/g;                      # regex meta-characters escaping

    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(\\\.\\\*\\\?)/$1($4|.*?)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(([^][wd\\.?*|()])\\([+*?]))/$1($4|$5$6)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)((\\\\\\[][\\.?*|()])\\\?)/$1($4|$5|)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(\\(\\[wd]))(?!\\[+*?])/$1($4|$5)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(\\(\\[wd])\\([+*?]))(?!\\\?)/$1($4|$5$6)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(\\(\\[wd])\\([+*?])\\(\?))/$1($4|$5$6$7)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(\\\(([^|)]*)\\\)\\\?)/$1($4|$5|)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(\\\(([^|)]*)\\\|([^|)]*)\\\))/$1($4|$5|$6)/g;
    $parentRegex =~ s/((\G|[^\\])(\\\\)*)(\\\[\\\\s\\\\S\\\]\\\*\\\?)/$1($4|[\\s\\S]*?)/g;

    return $parentRegex;
}

sub convertToRepl {
    my ($repl, $left, $right, $quote) = @_;

    $repl =~ s/\\b|\$$//;                                             # remove $ at the end and \b

    $repl =~ s/((\G|[^\\])(\\\\)*)\.\*\?/$1♦/g;
    $repl =~ s/((\G|[^\\])(\\\\)*)[^][\\.?*|()][+*?]/$1♦/g;
    $repl =~ s/((\G|[^\\])(\\\\)*)\\[][\\.?*|()][+*?]/$1♦/g;
    $repl =~ s/((\G|[^\\])(\\\\)*)\\[wd]([+*?]\??)?/$1♦/g;
    $repl =~ s/((\G|[^\\])(\\\\)*)\([^)]*\)\??/$1♦/g;
    $repl =~ s/((\G|[^\\])(\\\\)*)\[\\s\\S\]\*\?/$1♦/g;

    my $antiquote = ($quote eq "'") ? '"' : "'";
    $repl =~ s/$quote/$quote.$antiquote$quote$antiquote.$quote/g;     # quote escaping quotes

    my $i = 1;
    $i++ while $repl =~ s/((\G|[^\\])(\\\\)*)♦/$1$right$quote.\$$i.$quote$left/;
    $repl = $quote . $left . $repl . $right . $quote;

    $repl =~ s/((\G|[^\\])(\\\\)*)\\n/$1$right\\n$left/g;             # duplicate highlighting tags on newline

    return $repl;
}
