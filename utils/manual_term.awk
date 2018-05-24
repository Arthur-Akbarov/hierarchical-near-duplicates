#!/usr/bin/awk -f
#
# used by manual_tree.awk
# ./manual_term.awk -v parentRegex='polygons?' -v regex='polygon' -v printContext='1' > polygon.html
#

BEGIN {
    # print "DEBUG  parentRegex = " parentRegex  > "/dev/stderr";
    # print "DEBUG        regex = " regex        > "/dev/stderr";
    # print "DEBUG printContext = " printContext > "/dev/stderr";
}

{
    lines[NR] = $0;
}

END {
    printRegexDetailsStart(lines[1], parentRegex, regex);

    if (printContext) {
        i = 2;
        while (i <= NR)
            i = printContextTable(i);
    }

    printRegexDetailsEnd();
}

function printRegexDetailsStart(matches, parentRegex, regex) {
    # add zero width space to let use a ligature
    # gsub(/,/, ",\\&#8203;", matches);
    matches = gensub(/((,[^,]*){9},)/, "\\1\\&#8203;", "g", matches);

    gsub(/ = /, "</span><span> = ", matches);
    matches = "<span>" matches "</span>";

    print "\t<li><details>";
    print "\t\t<summary><!--";
    print "\t\t\t--><matches>" matches "</matches><!--";
    print "\t\t\t--><regex>" escapeHtml(highlightRegex(parentRegex, regex)) "</regex>";
    print "\t\t</summary>";

    if (printContext)
        print "\t\t<ol>";
    else
        print "\t\t<ul>";
}

function printRegexDetailsEnd() {
    if (printContext) {
        print "\t\t</ol>";
        print "\t</details></li>";
    }
    # else manual_tree.awk would printRegexDetailsEndForNotLeaf
}

function printContextTable(i) {
    printf "\t\t\t<li value=\"%s\"><table>\n", lines[i++];

    while (i <= NR && lines[i] !~ /^[0-9]+$/)
        printContextLine(lines[i++]);

    print "\t\t\t</table></li>";
    return i;
}

function printContextLine(line,    lineNumber, separator, pureLine) {
    match(line, /^[0-9]+[:-]/);
    lineNumber = substr(line, 0, RLENGTH - 1);
    separator = substr(line, RLENGTH, 1);
    pureLine = substr(line, RLENGTH + 1);

    print "\t\t\t\t<tr>";
    printf "\t\t\t\t\t<td>%s</td>\n", "<span>" lineNumber "</span><span>" separator "</span>";
    printf "\t\t\t\t\t<td>%s</td>\n", escapeHtml(pureLine);
    print "\t\t\t\t</tr>";
}

function highlightRegex(parentRegex, regex,    awkHighlightRegex, cmd, highlightedRegex) {
    gsub(/\\/, "\\\\&", parentRegex);             # awk backslash escaping
    gsub(/\\/, "\\\\&", regex);                   # awk backslash escaping

    gsub(/'/, "'\"'\"'", parentRegex);            # shell single quote escaping
    gsub(/'/, "'\"'\"'", regex);                  # shell single quote escaping

    awkHighlightRegex = ENVIRON["_"];
    sub(/[^/]+$/, "highlightRegex.awk", awkHighlightRegex);

    cmd = awkHighlightRegex " -v parentRegex='" parentRegex "' -v regex='" regex "'";
    # print "DEBUG " cmd > "/dev/stderr";

    cmd | getline highlightedRegex;
    # print "DEBUG highlightedRegex = " highlightedRegex > "/dev/stderr";

    close(cmd);
    return highlightedRegex;
}

function escapeHtml(text) {
    gsub(/&/, "\\&amp;", text);
    gsub(/</, "\\&lt;", text);
    gsub(/>/, "\\&gt;", text);

    text = gensub(/♠([^♠]+)♠/, "<\\1>", "g", text);

    text = gensub(/♠([^♠]+)♠/, "<\\1>", "g", text);
    text = gensub(/♥([^♥]+)♥/, "</\\1>", "g", text);

    return text;
}
