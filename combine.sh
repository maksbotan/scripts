#!/bin/bash

if [ x$1 = 'x-h' ]; then
    echo "Usage:"
    echo "$0 width height output file1 file2 ..."
    exit
fi

w=$1
h=$2
out=$3
shift 3
ext=${out##*.}
total=$(($w*$h))

acc=$(mktemp tmp.acc.XXXXX.$ext)
number=1

mangle(){
    var=$1
    while [ $(expr length $var) -le 3 ]; do
        var=0$var
    done
    echo $var
}

for j in $(seq 1 $h); do
    row=$(mktemp tmp.row.XXXX.$ext)
    for i in $(seq 1 $w); do
        if [ $(expr length $number) -le 4 ]; then
            name=$(mangle $number)
        else
            name=$number
        fi
        if [ $i = 1 ]; then
            cp _${name}__.png $row
        else
            convert +append $row _${name}__.png $row
        fi
        number=$(($number+1))
    done
    if [ $j = 1 ]; then
        cp $row $acc
    else
        convert -append $acc $row $acc
    fi
    rm $row
done

cp $acc $out
rm $acc
