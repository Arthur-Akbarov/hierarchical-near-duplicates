#!/usr/bin/awk -f
#
# ./input2js.awk input > title.js
#

BEGIN {
    indent = "    ";
    indent2 = indent indent;
    indent3 = indent2 indent;

    print "function getSource() {";
    print indent "return '' +";
    print indent "'<table><tbody>\\n' +"
}

{
    printf int(NR / 1000) " thousands of input lines \r" > "/dev/stderr";

    print indent2 "'<tr>\\n' +";
    print indent3 "'<td><a name=" NR ">" NR "</a></td>\\n' +";
    print indent3 "'<td>" escapeJavaSript(escapeHtml($0)) "</td>\\n' +";
    print indent2 "'</tr>\\n' +";
}

END {
    print indent "'</tbody></table>';";
    print "}";
}

function escapeJavaSript(text) {
    gsub(/\\/, "\\\\", text);                     # javascript backslash escaping
    gsub(/'/, "' + \"'\" + '", text);             # javascript single quote escaping

    return text;
}

function escapeHtml(text) {
    gsub(/&/, "\\&amp;", text);
    gsub(/</, "\\&lt;", text);
    gsub(/>/, "\\&gt;", text);

    return text;
}
