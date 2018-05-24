#!/usr/bin/awk -f
#
# manually run only from src/sourceTitle
# ../../utils/manual_tree.awk -v sourceTitle='eclipseSWT' polygons.re > ../../web/html/openLDAP/manual/polygons.html
#

BEGIN {
    # print "DEBUG manual_tree.awk -v sourceTitle='" sourceTitle "'" > "/dev/stderr";
}

{
    if (NR == 1) {
        regex[++regexCount] = $0;
        # printf "DEBUG     regex[%02d] = %s\n", regexCount, regex[regexCount] > "/dev/stderr";
        level[regexCount] = 0;
        next;
    }

    if ($0 ~ /^$/ || $0 ~ /^[ \t]*#/)
        next;

    if (gotIndent == 0 && match($0, /^( +|\t+)/)) {
        indent = substr($0, 0, RSTART + RLENGTH - 1);
        gotIndent = 1;
    }

    if (gotIndent)
        while ( sub("^" indent, "", $0) )
            curLevel++;

    if (curLevel - prevLevel > 1) {
        printf "ERROR_INVALID_LEVELOFFSET, at line %d in \"%s\"\n", NR, FILENAME > "/dev/stderr";
        error = 1;
        exit;
    }

    if (curLevel == prevLevel + 1)
        if (prevIsArchetype == 0) {
            regex[++regexCount] = $0;
            # printf "DEBUG +1  regex[%02d] = %s\n", regexCount, regex[regexCount] > "/dev/stderr";
            level[regexCount] = curLevel;
        } else {
            printf "ERROR_MISSED_REGEX, at line %d in \"%s\"\n", NR, FILENAME > "/dev/stderr";
            error = 1;
            exit;
        }

    if (curLevel == prevLevel)
        if (prevIsArchetype == 0) {
            curIsArchetype = 1;
            archetype[regexCount] = $0;
            # printf "DEBUG archetype[%02d] = %s\n", regexCount, regex[regexCount] > "/dev/stderr";
            isLeaf[regexCount] = 1;
        } else {
            curIsArchetype = 0;
            regex[++regexCount] = $0;
            # printf "DEBUG  0  regex[%02d] = %s\n", regexCount, regex[regexCount] > "/dev/stderr";
            level[regexCount] = curLevel;
        }

    if (curLevel < prevLevel)
        if (prevIsArchetype == 0) {
            printf "ERROR_MISSED_ARCHETYPE, at line %d in \"%s\"\n", NR, FILENAME > "/dev/stderr";
            error = 1;
            exit;
        } else {
            curIsArchetype = 0;
            regex[++regexCount] = $0;
            # printf "DEBUG -k  regex[%02d] = %s\n", regexCount, regex[regexCount] > "/dev/stderr";
            level[regexCount] = curLevel;
        }

    prevIsArchetype = curIsArchetype;
    prevLevel = curLevel;
    curLevel = 0;
}

END {
    if (error) exit;

    if (prevIsArchetype == 0) {
        printf "ERROR_MISSED_LAST_ARCHETYPE, at line %d in \"%s\"\n", NR, FILENAME > "/dev/stderr";
        exit;
    }

    printHtmlHead();

    i = 1;
    while (i <= regexCount)
        i = printSubTree(i);

    printHtmlFooter();
}

function printSubTree(myindex, parentindex,    cmd, i, indent, line, nextindex) {
    printf myindex "/" regexCount " regexes\r" > "/dev/stderr";

    # for (i = 1; i < regexCount; i++) {
    #     printf "regex[%02d]     = %s\n", i, regex[i]      > "/dev/stderr";
    #     printf "archetype[%02d] = %s\n", i, archetype[i]  > "/dev/stderr";
    #     printf "level[%02d]     = %s\n", i, level[i]      > "/dev/stderr";
    #     printf "isLeaf[%02d]    = %s\n", i, isLeaf[i]     > "/dev/stderr";
    #     print  ""                                         > "/dev/stderr";
    # }
    # exit;

    cmd = getContextCmd(regex[parentindex], regex[myindex], archetype[myindex], isLeaf[myindex]);

    for (i = 0; i < level[myindex]; i++)
        indent = indent "\t\t";

    while ( ( cmd | getline line ) > 0 )
        print indent line;

    close(cmd);

    nextindex = myindex + 1;

    if (!isLeaf[myindex]) {
        while (level[nextindex] == level[myindex] + 1)
            nextindex = printSubTree(nextindex, myindex);

        printRegexDetailsEndForNotLeaf(indent);
    }

    return nextindex;
}

function printRegexDetailsEndForNotLeaf(indent) {
    print indent "\t\t</ol>";
    print indent "\t</details></li>";
}

function getContextCmd(parentRegex, regex, archetype, isLeaf,    awkParentRegex, grepRegex, awkRegex, perlHighlight, lineNumbersFileName, awkTerm, cmd) {
    awkParentRegex = parentRegex;
    awkRegex = regex;
    grepRegex = regex;
    perlRegex = regex;

    gsub(/\\/, "\\\\&", awkParentRegex);          # awk backslash escaping
    gsub(/\\/, "\\\\&", awkRegex);                # awk backslash escaping

    gsub(/'/, "'\"'\"'", archetype);              # shell single quote escaping
    gsub(/'/, "'\"'\"'", awkParentRegex);         # shell single quote escaping
    gsub(/'/, "'\"'\"'", awkRegex);               # shell single quote escaping
    gsub(/'/, "'\"'\"'", grepRegex);              # shell single quote escaping
    gsub(/'/, "'\"'\"'", perlRegex);              # shell single quote escaping

    perlHighlight = ENVIRON["_"];
    sub(/[^/]+$/, "highlightRepeats.pl", perlHighlight);

    perlCount = ENVIRON["_"];
    sub(/[^/]+$/, "getRepeatsCount.pl", perlCount);

    if (lineNumbers == "") {
        lineNumbers = FILENAME;
        sub(/[^.]*$/, "ln", lineNumbers);
    }

    awkTerm = ENVIRON["_"];
    sub(/[^\/]+$/, "manual_term.awk", awkTerm);

    if (input == "") {
        input = FILENAME;
        sub(/[^\/]+$/, "input", input);
    }

    cmd = isLeaf ?
        "perl '" perlHighlight "' '" lineNumbers "' '" perlRegex "' '" archetype "' '" input "' | " :
        # "grep -nPe '" grepRegex "' " input " | awk '{if (NR == 1) print $0; else print \"--\\n\" $0;}' | ";
        "perl '" perlCount "' '" lineNumbers "' '" perlRegex "' '" input "' | ";

    cmd = cmd awkTerm " -v parentRegex='" awkParentRegex "' -v regex='" awkRegex "'";
    cmd = isLeaf ? cmd  " -v printContext='1'" : cmd;
    # print "DEBUG " cmd > "/dev/stderr";

    return cmd;
}

function printHtmlHead() {
    if (htmlTitle == "") {
        htmlTitle = FILENAME;
        sub(/\.[^.]*$/, "", htmlTitle);
    }

    if (sourceTitle == "") {
        sourceTitle = FILENAME;
        sourceTitle = gensub(/\/([^\/]+)\/[^\/]+$/, "\\1", 1, sourceTitle);
    }

    print "<!DOCTYPE html>";
    print "<html>";
    print "<head>";
    print "\t<title>" htmlTitle "</title>";
    print "\t<meta charset=\"utf-8\">";
    print "\t<meta name=\"sourceTitle\" content=\"" sourceTitle "\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/loader.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/scrollbar.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/sidebar.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/tree_li.css\">";
    print "\t<link rel=\"stylesheet\"           href=\"../../../css/tree_light.css\" title=\"light\">";
    print "\t<link rel=\"stylesheet alternate\" href=\"../../../css/tree_dark.css\"  title=\"dark\">";
    print "\t<script src='../../../js/tree.js'></script>";
    print "</head>";
    print "<body>";
    print "\t<div id=\"sidebar\">";
    print "\t\t<button onclick=\"window.location.href='../../manual_browser.html'\">back</button>";
    print "\t\t<button id=\"toggleTheme\"      onclick=\"toggleTheme()\">dark theme</button>";
    print "\t\t<button id=\"toggleSourcePane\" onclick=\"toggleSourcePane()\">show source</button>";
    print "\t</div>";
    print "\t<div id=\"top\"><ul>";
}

function printHtmlFooter() {
    print "\t</ul></div>";
    print "\t<div id=\"resizer\"></div>";
    print "\t<div id=\"bottom\"></div>";
    print "</body>";
    print "</html>";
}
