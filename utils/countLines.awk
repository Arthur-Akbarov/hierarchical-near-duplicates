#!/usr/bin/awk -f
#
# ./countLines.awk filename.pl
# works inplace
#

{
    while (match($0, /([0-9]+)-([0-9]+)(=[0-9]*)?/, array)) {
        count = array[2] - array[1] + 1;
        start = substr($0, 0, array[2, "start"] + array[2, "length"] - 1);
        line = line start "=" count;
        $0 = substr($0, RSTART + RLENGTH);
    }

    lines[NR] = line $0;
    line = "";
}

END {
    for (i = 1; i <= NR; i++)
        print lines[i] > FILENAME;
}
