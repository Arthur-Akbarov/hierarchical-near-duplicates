#!/usr/bin/awk -f
#
# used by auto_tree.awk
# ./auto_term.awk -v parentERE='polygons?' -v ERE='polygon' -v debug='1' > polygon.html
#

BEGIN {
    IGNORECASE = 1;

    # print "DEBUG parentERE = " parentERE > "/dev/stderr";
    # print "DEBUG       ERE = " ERE       > "/dev/stderr";
}

{
    gsub(/^ */, "", $0);
    count[NR] = $1;
    sum += $1;
    terms[NR] = substr($0, length($1) + 2);
}

END {
    printRegexDetailsStart(sum, parentERE, ERE);

    for (i = 1; i <= NR; i++) {
        printTermDetails(count[i], ERE, terms[i]);

        if (i < NR)
            print "";
    }

    printRegexDetailsEnd();
}

function printRegexDetailsStart(sum, parentERE, ERE) {
    print "\t<li><details>";
    print "\t\t<summary><!--";
    print "\t\t\t--><matches>" sum "</matches><!--";
    print "\t\t\t--><regex>" escapeHtml(highlightERE(parentERE, ERE)) "</regex>";
    print "\t\t</summary>";
    print "\t\t<ol>";
    # place to insert child nodes
    print "\t\t\t<li><details><summary><span>terms</span></summary><ol class=\"terms\">";
}

function printRegexDetailsEnd() {
    print "\t\t\t</ol></details></li>";
    print "\t\t</ol>";
    print "\t</details></li>";
}

function printTermDetails(count, ERE, term,    highlightedTerm, termRegex) {
    highlightedTerm = highlightText(ERE, term);

    print "\t\t\t\t<li><details>";
    print "\t\t\t\t\t<summary><!--";
    print "\t\t\t\t\t\t--><terms>" count "</terms><!--";
    print "\t\t\t\t\t\t--><term>" escapeHtml(highlightedTerm) "</term>";
    print "\t\t\t\t\t</summary>";
    print "\t\t\t\t\t<table><tbody>";

    # grep and awk regex meta-characters escaping
    termRegex = gensub(/[][\\.?*+|(){}^$]/, "\\\\&", "g", term);
    printConextList(termRegex, highlightedTerm);

    print "\t\t\t\t\t</tbody></table>";
    print "\t\t\t\t</details></li>";
}

function printConextList(termRegex, highlightedTerm,    cmd, firstGroup) {
    cmd = getContextCmd(termRegex);

    firstGroup = 1;

    while ( ( cmd | getline firstLine ) > 0 ) {
        if (firstGroup == 1) {
            firstGroup = 0;
        } else {
            print "\t\t\t\t\t\t<tr class=\"padding\"></tr>";
            print "\t\t\t\t\t\t<tr class=\"hr\"><td></td><td></td></tr>";
            print "\t\t\t\t\t\t<tr class=\"padding\"></tr>";
        }

        printContextGroup(firstLine, termRegex, highlightedTerm, cmd);
    }

    close(cmd);
}

function getContextCmd(termRegex,    cmd) {
    gsub(/'/, "'\"'\"'", termRegex);              # shell single quote escaping

    cmd = "grep -3inEe '" termRegex "' input";
    # print "DEBUG " cmd > "/dev/stderr";

    return cmd;
}

function printContextGroup(firstLine, termRegex, highlightedTerm, cmd,    line) {
    printContextLine(firstLine, termRegex, highlightedTerm);

    while ( ( cmd | getline line ) > 0 ) {
        if (line ~ /^--$/)
            break;

        printContextLine(line, termRegex, highlightedTerm);
    }
}

function printContextLine(line, termRegex, highlightedTerm,    lineNumber, separator, pureLine) {
    match(line, /^[0-9]+[:-]/);
    lineNumber = substr(line, 0, RLENGTH - 1);
    separator = substr(line, RLENGTH, 1);
    pureLine = substr(line, RLENGTH + 1);

    if (separator == ":")
        highlightedLine = gensub(termRegex, "♠h♠" highlightedTerm "♥h♥", "g", pureLine);
    else
        highlightedLine = pureLine;

    print "\t\t\t\t\t\t<tr>";
    printf "\t\t\t\t\t\t\t<td>%s</td>\n", "<span>" lineNumber "</span><span>" separator "</span>";
    printf "\t\t\t\t\t\t\t<td>%s</td>\n", escapeHtml(highlightedLine);
    print "\t\t\t\t\t\t</tr>";
}

function highlightERE(parentERE, ERE,    highlightEREScript, cmd, highlightedERE) {
    gsub(/\\/, "\\\\&", parentERE);               # awk backslash escaping
    gsub(/\\/, "\\\\&", ERE);                     # awk backslash escaping

    gsub(/'/, "'\"'\"'", parentERE);              # shell single quote escaping
    gsub(/'/, "'\"'\"'", ERE);                    # shell single quote escaping

    highlightEREScript = ENVIRON["_"];
    sub(/[^/]+$/, "highlightERE.awk", highlightEREScript);

    cmd = highlightEREScript " -v parentERE='" parentERE "' -v ERE='" ERE "'";
    # print "DEBUG " cmd > "/dev/stderr";

    cmd | getline highlightedERE;
    # print "DEBUG highlightedERE = " highlightedERE > "/dev/stderr";

    close(cmd);
    return highlightedERE;
}

function highlightText(ERE, text,    highlightTextScript, cmd, highlightedText) {
    gsub(/\\/, "\\\\&", ERE);                     # awk backslash escaping
    gsub(/\\/, "\\\\&", text);                    # awk backslash escaping

    gsub(/'/, "'\"'\"'", ERE);                    # shell single quote escaping
    gsub(/'/, "'\"'\"'", text);                   # shell single quote escaping

    highlightTextScript = ENVIRON["_"];
    sub(/[^/]+$/, "highlightText.awk", highlightTextScript);

    cmd = highlightTextScript " -v ERE='" ERE "' -v text='" text "'";
    # print "DEBUG " cmd > "/dev/stderr";

    cmd | getline highlightedText;
    # print "DEBUG highlightedText = " highlightedText > "/dev/stderr";

    close(cmd);
    return highlightedText;
}

function escapeHtml(text) {
    gsub(/&/, "\\&amp;", text);
    gsub(/</, "\\&lt;", text);
    gsub(/>/, "\\&gt;", text);

    text = gensub(/♠([^♠]+)♠/, "<\\1>", "g", text);
    text = gensub(/♥([^♥]+)♥/, "</\\1>", "g", text);

    return text;
}
