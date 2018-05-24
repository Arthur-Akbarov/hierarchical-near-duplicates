#!/usr/bin/awk -f
#
# manually run only from src/sourceTitle
# ../../utils/auto_tree.awk -v sourceTitle='openLDAP' -v withoutAB='0' polygons.re > ../../web/html/openLDAP/auto/polygons.html
#

BEGIN {
    # print "DEBUG auto_tree.awk -v sourceTitle='" sourceTitle "'" > "/dev/stderr";
}

{
    if (NR != 1) {
        if (NR == 2)
            indent = ($0 ~ /^    /) ? "    " : "\t";

        while ( sub("^" indent, "", $0) )
            level[NR]++;
    }

    B[NR] = $1;
    A[NR] = $2;
    regex[NR] = $0;

    if (level[NR] - level[NR - 1] > 1) {
        printf "ERROR_INVALID_LEVELOFFSET, level[%d] - level[%d] > 1", NR, NR - 1 > "/dev/stderr";
        exit;
    }

    if (level[NR] <= level[NR - 1])
        isLeaf[NR - 1] = 1;
}

END {
    isLeaf[NR] = 1;

    printHtmlHead();

    i = 1;
    while (i <= NR)
        i = printSubTree(i);

    printHtmlFooter();
}

function printSubTree(myindex, parentindex,    i, indent, cmd, line, lines, j, nextindex) {
    printf myindex "/" NR " regexes\r" > "/dev/stderr";

    if (!withoutAB && isLeaf[myindex])
        regex[myindex] = substr(regex[myindex], length(B[myindex]) + length(A[myindex]) + 3);

    cmd = getContextCmd(regex[parentindex], regex[myindex]);

    for (i = 0; i < level[myindex]; i++)
        indent = indent "\t\t";

    while ( ( cmd | getline line ) > 0 ) {
        print indent line;

        if (line ~ /^\t*<ol>$/)
            break;
    }

    while ( ( cmd | getline line ) > 0 )
        lines[j++] = line;

    close(cmd);

    nextindex = myindex + 1;
    while (level[nextindex] == level[myindex] + 1)
        nextindex = printSubTree(nextindex, myindex);

    for (i = 0; i < j; i++)
        print indent lines[i];

    return nextindex;
}

function getContextCmd(parentERE, ERE,    grepERE, termScript, cmd) {
    grepERE = ERE;

    gsub(/\\/, "\\\\&", parentERE);               # awk backslash escaping
    gsub(/\\/, "\\\\&", ERE);                     # awk backslash escaping

    gsub(/'/, "'\"'\"'", grepERE);                # shell single quote escaping
    gsub(/'/, "'\"'\"'", parentERE);              # shell single quote escaping
    gsub(/'/, "'\"'\"'", ERE);                    # shell single quote escaping

    termScript = ENVIRON["_"];
    sub(/[^/]+$/, "auto_term.awk", termScript);

    removeOddsScript = ENVIRON["_"];
    sub(/[^/]+$/, "removeOdds.awk", removeOddsScript);

    cmd = "grep -iP '" grepERE "' input | ";
    # cmd = removeOdds ? cmd removeOddsScript  " | " : cmd;
    # cmd = (sourceTitle == "eclipseSWT") ? cmd removeOddsScript  " | " : cmd;
    cmd = cmd "grep -ioP '(?<edge>[^\\w\\s]*)(?:\\b(?<in>e\\.?g\\.|i\\.?e\\.|etc\\.(?= (?-i:[a-z])++(?!_|\\())|\\.\\.[\\.\\/]|!=|[.!?](?!(?: |[^\\w\\s]+ [^\\w\\s]*(?-i:[A-Z])))|[^\\n.!?])*)?" grepERE "(?(?<=[^.!?])(?:(?&in)*\\b)?)(?&edge)' | sort | uniq -c | sort -k1nr | " termScript " -v parentERE='" parentERE "' -v ERE='" ERE "'";
    # print "DEBUG " cmd > "/dev/stderr";

    return cmd;
}

function printHtmlHead() {
    sub(/\.[^\.]*$/, "", FILENAME);

    print "<!DOCTYPE html>";
    print "<html>";
    print "<head>";
    print "\t<title>" FILENAME "</title>";
    print "\t<meta charset=\"utf-8\">";
    print "\t<meta name=\"sourceTitle\" content=\"" sourceTitle "\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/loader.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/scrollbar.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/sidebar.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/tree.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/tree_light.css\" title=\"light\">";
    print "\t<link rel=\"stylesheet alternate\" href=\"../../../css/tree_dark.css\"  title=\"dark\">";
    print "\t<script src='../../../js/tree.js'></script>";
    print "</head>";
    print "<body>";
    print "\t<div id=\"sidebar\">";
    print "\t\t<button onclick=\"window.location.href='../../auto_browser.html'\">back</button>";
    print "\t\t<button id=\"toggleTheme\"      onclick=\"toggleTheme()\">dark theme</button>";
    print "\t\t<button id=\"toggleSourcePane\" onclick=\"toggleSourcePane()\">show source</button>";
    print "\t</div>";
    print "\t<div id=\"top\"><ol>";
}

function printHtmlFooter() {
    print "\t</ol></div>";
    print "\t<div id=\"resizer\"></div>";
    print "\t<div id=\"bottom\"></div>";
    print "</body>";
    print "</html>";
}
