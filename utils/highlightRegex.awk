#!/usr/bin/awk -f
#
# used by auto_term.awk, manual_term.awk
# ./highlightRegex.awk -v parentRegex='a.*c' -v regex='abc' -v debug='1'
# ../../utils/highlightRegex.awk 2>/dev/stdout | grep -P '[][{}]|$' --color
#

BEGIN {
    IGNORECASE = 1;
    # debug = 1;

    if (debug == 1) {
        # parentRegex = "a \\w d \\d e";
        # regex       = "a b d 1 e";

        # parentRegex = "a \\w+ d \\d+ e";
        # regex       = "a bc d 12 e";

        # parentRegex = "when .*? events?.*? occurs?";
        # regex       = "when an event of the given type occurs";

        # parentRegex = "a[\\s\\S]*b.*c";  # awk regex do not know \s \S
        # regex       = "a.*dbec";

        # parentRegex = "a.*b.*c";
        # regex = "a.*dbec";              #  [a]{*}d[b]{*}d[c]

        # parentRegex = "a.*?b.*?c";
        # regex = "a.*?dbec";             #  [a]{*}d[b]{*}d[c]

        # parentRegex = "a.*b.*cd?";
        # regex = "a.*d.*becd?"

        # parentRegex = "byte";
        # regex = "byte .* of"

        # parentRegex = "(a|b)cd?";
        #       regex = "acd";

        # parentRegex = "\\\\\\\\";
        #      regex  = "\\\\\\\\a";

        # parentRegex = "\\(";
        #      regex  = "\\(a";

        # parentRegex = "'a.*c\"";
        #      regex  = "'abc\"";

        # parentRegex = "\\ba/b/?";
        #      regex  = "\\ba/b/?c";

        # parentRegex = "a\\)b\\(?";
        #      regex  = "a\\)b\\(?c";

        # parentRegex = "\\.?a";
        #      regex  = "\\.?ab";

        # parentRegex = "\\\\(a|b)(c|d)";
        #      regex  = "\\\\ac";

        # parentRegex = "";
        #      regex  = "zb.*c\\?d?(e|f)";

        # parentRegex = "b.*c\\?d?(e|f)";
        #      regex  = "zb.*c\\?d?(e|f)";

        print "parentRegex     = " parentRegex > "/dev/stderr";
        print "     regex      = " regex       > "/dev/stderr";
    }

    gsub(/\[\\s\\S\]\*\?|\.\*\?/, ".*", parentRegex);
    gsub(/\[\\s\\S\]\*\?|\.\*\?/, ".*", regex);

    gsub(/\\b/, "", parentRegex);            # remove \b
    gsub(/\\b/, "", regex);                  # remove \b

    regex = highlightRegex(parentRegex, regex);

    if (debug == 1) {
        print "simpParentRegex = " simplify(parentRegex) > "/dev/stderr";
        print "  highlighRegex = " regex                 > "/dev/stderr";
        print "      simpRegex = " simplify(regex)       > "/dev/stderr";
    } else {
        print simplify(regex)
    }
}

function highlightRegex(parentRegex, regex,    i, repl, left, right) {
    if (parentRegex == "")
        return regex;

    repl = parentRegex;
    # print "\n\nrepl0 = " repl > "/dev/stderr";

    # print "parentRegex1 = " parentRegex > "/dev/stderr";
    gsub(/[\\.+?*|(){}]/, "\\\\&", parentRegex);       # regex meta-characters escaping

    # TODO write workaround instead of perl \G to deal with consequently substrings, e.g. a?b?
    # regex prefix ((^|[^\\])(\\\\)*) demand at least one character and b? does not match
    parentRegex = gensub(/((^|[^\\])(\\\\)*)(\\\.\\([+*?])(\\\?)?)/,          "\\1(\\4|.\\5\\6)", "g", parentRegex);
    parentRegex = gensub(/((^|[^\\])(\\\\)*)(([^\\.?*|()])\\\?)/,             "\\1(\\4|\\5?)",    "g", parentRegex);
    parentRegex = gensub(/((^|[^\\])(\\\\)*)((\\\\\\[][\\.?*|()])\\\?)/,      "\\1(\\4|\\5|)",    "g", parentRegex);
    parentRegex = gensub(/((^|[^\\])(\\\\)*)(\\\\w(\\([+*?]))?)/,     "\\1(\\4|[a-zA-Z0-9_]\\6)", "g", parentRegex);
    parentRegex = gensub(/((^|[^\\])(\\\\)*)(\\\\d(\\([+*?]))?)/,            "\\1(\\4|[0-9]\\6)", "g", parentRegex);
    parentRegex = gensub(/((^|[^\\])(\\\\)*)(\\\(([^|)]*)\\\)\\\?)/,          "\\1(\\4|\\5|)",    "g", parentRegex);
    parentRegex = gensub(/((^|[^\\])(\\\\)*)(\\\(([^|)]*)\\\|([^|)]*)\\\))/,  "\\1(\\4|\\5|\\6)", "g", parentRegex);

    # print "repl0 = " repl        > "/dev/stderr";
    sub(/\\b$|[$^]/, "", repl);                   # remove \b at the end, ^, $ anchors

    # here for loop is workaround instead of perl \G
    for (i = 1; i <= 2; i++) {
        repl = gensub(/((^|[^\\])(\\\\)*)\.[+*?]\??/,          "\\1♦", "g", repl);
        repl = gensub(/((^|[^\\])(\\\\)*)[^\\.?*|()][+*?]/,    "\\1♦", "g", repl);
        repl = gensub(/((^|[^\\])(\\\\)*)\\[\\.?*|()][+*?]/,   "\\1♦", "g", repl);
        repl = gensub(/((^|[^\\])(\\\\)*)\\[dw][+*?]?/,        "\\1♦", "g", repl);
        repl = gensub(/((^|[^\\])(\\\\)*)\([^)]*\)/,           "\\1♦", "g", repl);
        repl = gensub(/((^|[^\\])(\\\\)*)(\[\\s\\S\]\*)/,      "\\1♦", "g", repl);
    }
    # print "repl2 = " repl        > "/dev/stderr";

    gsub(/[\\&]/, "\\\\&", repl);            # replacement meta-characters escaping

    left  = (debug > 0) ? "[" : "♠c♠";
    right = (debug > 0) ? "]" : "♥c♥";

    for (i = 1; i <= 9; i++) {
        # print "repl for " i " = " repl > "/dev/stderr";
        repl = gensub(/((^|[^\\])(\\\\)*)♦/, "\\1" right "\\\\" i left, 1, repl);
    }

    repl = left repl right;
    # print "regex       = " regex       > "/dev/stderr";
    # print "parentRegex = " parentRegex > "/dev/stderr";
    # print "repl        = " repl        > "/dev/stderr";

    return gensub(parentRegex, repl, "g", regex);
}

function simplify(regex,    left, right, repl) {
    left  = (debug > 0) ? "{" : "♠m♠";
    right = (debug > 0) ? "}" : "♥m♥";

    repl = "\\1" left "\\4" right;

    regex = gensub(/((^|[^\\])(\\\\)*)\.([+*?])\??/,            repl, "g", regex);  # substitute .* and .*? with * and highlight
    regex = gensub(/((^|[^\\])(\\\\)*)([^{♠\\.?*|()][+*?])\??/, repl, "g", regex);  # highlight a?
    regex = gensub(/((^|[^\\])(\\\\)*)\\([\\.?*|()][+*?])\??/,  repl, "g", regex);  # highlight \.?
    # regex = gensub(/((^|[^\\])(\\\\)*)\\([dw][+*?]?)\??/,       repl, "g", regex);  # highlight \d, \d?
    regex = gensub(/((^|[^\\])(\\\\)*)(\([^)]*\)\??)/,          repl, "g", regex);  # highlight (e|f)
    regex = gensub(/((^|[^\\])(\\\\)*)(\$)/,                    repl, "g", regex);  # highlight $ at the end

    regex = gensub(/((^|[^\\])(\\\\)*)\\d[+*]\??/,   "\\1" left "digits" right, "g", regex);  # highlight \d+, \d*
    regex = gensub(/((^|[^\\])(\\\\)*)\\d\??\??/,    "\\1" left "digit"  right, "g", regex);  # highlight \d
    regex = gensub(/((^|[^\\])(\\\\)*)\\w[+*]\??/,   "\\1" left "word"   right, "g", regex);  # highlight \w+, \w*
    regex = gensub(/((^|[^\\])(\\\\)*)\\w\??\??/,    "\\1" left "letter" right, "g", regex);  # highlight \w
    regex = gensub(/((^|[^\\])(\\\\)*)\\n/,          "\\1" left " "      right, "g", regex);  # substitute \n with space

    regex = gensub(/\\([\\.+?*|(){}^$])/, "\\1", "g", regex);    # unescape regex meta-characters

    return regex;
}

function substitute() {

}
