#!/usr/bin/sh
#
# ./tree.sh sourceTitle [filename]
#
# sourceTitle - document name
# filename - regexes filename in src/sourceTitle without ".re" extension
#

[ -z ${1+x} ] && { echo "First argument (sourceTitle) is unset!"; exit 1; }
[ -z "$1" ] && { echo "First argument (sourceTitle) is empty!"; exit 2; }

sourceTitle="$1"

repo="$(dirname "$(dirname "$(readlink -f "$0")")")"
dir="$repo/src/$sourceTitle"

[ ! -d "$dir" ] && { echo "Directory 'src/$sourceTitle' does not exist!"; exit 3; }
cd "$dir"

if [ -n "${2+x}" ]; then
    [ -z "$2" ] && { echo "Second argument (filename) is empty!"; exit 4; }

    filename="$2".re
    [ ! -f "$filename" ] && { echo "File 'src/$sourceTitle/$filename' does not exist!"; exit 5; }

    ../../utils/auto_tree.awk -v sourceTitle="$sourceTitle" "$filename" > "../../web/html/$sourceTitle/auto/${filename/%.*/.html}"
    ../../utils/manual_tree.awk -v sourceTitle="$sourceTitle" "$filename" > "../../web/html/$sourceTitle/manual/${filename/%.*/.html}"
else
    for filename in *.re; do
        echo -e "             \r${filename/%.*}"
        ../../utils/auto_tree.awk -v sourceTitle="$sourceTitle" "$filename" > "../../web/html/$sourceTitle/auto/${filename/%.*/.html}"
        ../../utils/manual_tree.awk -v sourceTitle="$sourceTitle" "$filename" > "../../web/html/$sourceTitle/manual/${filename/%.*/.html}"
    done
fi


