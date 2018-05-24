#!/usr/bin/awk -f
#
# used by auto_term.awk, manual_term.awk
# ./highlightText.awk -v ERE='a.*c' -v text='abc' -v debug='1'
#

BEGIN {
    IGNORECASE = 1;
    # debug = 1;

    if (debug == 1) {
        # ERE="a\\db";                      # awk does not know \d pattern, but we teach
        # text="a1b";                       # [a]1[b]

        # ERE="\\\\";
        # text="a\\\\?b\\\\c\\?d\\e?fg";    # a[\][\]?b[\][\]c[\]?d[\]e?fg

        # ERE="\\\\\\?";
        # text="a\\\\?b\\\\c\\?d\\e?fg";    # a\[\?]b\\c[\?]d\e?fg

        # ERE="\\\\?";
        # text="a\\\\?b\\\\c\\?d\\e?fg";    # a[]\[][]\[]?b[]\[][]\[]c[]\[]?d[]\[]e?fg

        # ERE="a\\\\?";
        # text="a\\\\?b\\\\c\\?d\\e?fg";    # [a]\[]\?b\\c\?d\e?fg

        # ERE="\\?";
        # text="a\\\\?b\\\\c\\?d\\e?fg";    # a\\[?]b\\c\[?]d\e[?]fg

        # ERE="\\?";
        # text="\\";                        # \

        # ERE="\\?";
        # text="?";                         # [?]

        # ERE="a.*c\\$d?e(f|g)$";
        # text="^abc$def";                  # ^[a]b[c$]d[e]f[]

        # ERE="a.*cd?e(f|g)$";
        # text="^abcdef$";                  # ^abcdef$

        print "ERE  = " ERE  > "/dev/stderr";
        print "text = " text > "/dev/stderr";
    }

    if (ERE == "")
        print text;

    if (debug == 1) {
        left = "[";
        right = "]";
    } else {
        left = "♠c♠";
        right = "♥c♥";
    }

    # doubled to deal with consequently substrings, e.g. a?b?
    # regex prefix ((^|[^\\])(\\\\)*) demand at least one character and b? does not match
    for (i = 1; i <= 2; i++)
        ERE = gensub(/((^|[^\\])(\\\\)*)((\.|\\w)[+*?]?)/, "\\1(\\4)", "g", ERE);
    for (i = 1; i <= 2; i++)
        ERE = gensub(/((^|[^\\])(\\\\)*)([^\\.?*|()][+*?])/, "\\1(\\4)", "g", ERE);
    for (i = 1; i <= 2; i++)
        ERE = gensub(/((^|[^\\])(\\\\)*)(\\[\\.?*|()][+*?])/, "\\1(\\4)", "g", ERE);
    for (i = 1; i <= 2; i++)
        ERE = gensub(/((^|[^\\])(\\\\)*)\\d([+*?])?/, "\\1([0-9]\\4)", "g", ERE);

    repl = ERE;

    gsub(/[&]/, "\\\\&", repl);                   # replacement meta-characters escaping
    sub(/\$$/, "", repl);                         # remove $ at the end

    for (i = 1; i <= 9; i++)
        repl = gensub(/((^|[^\\])(\\\\)*)\([^)]*\)/, "\\1" right "\\\\" i left, 1, repl);

    repl = left repl right;

    if (debug == 1) {
        print "ERE  = " ERE  > "/dev/stderr";
        print "repl = " repl > "/dev/stderr";
    }

    print gensub(ERE, repl, "g", text);
}
