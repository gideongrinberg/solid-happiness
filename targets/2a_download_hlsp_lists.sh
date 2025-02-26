#! /usr/bin/env bash
set -e

mkdir -p hlsp_lists
mkdir -p hlsp_lists/tglc
mkdir -p hlsp_lists/qlp


download() {
    local product="$1"
    local max_sector="$2"

    url_list="./hlsp_lists/${product}_urls.txt"
    rm -f "$url_list"

    for i in $(seq -f "%04g" 1 "$max_sector"); do
        echo "https://archive.stsci.edu/hlsps/${product}/target_lists/s${i}.csv" >> "$url_list"
    done

    aria2c -d "./hlsp_lists/${product}" -x 16 -j 16 -i $url_list

    for file in ./hlsp_lists/${product}/*; do
        local dir="./hlsp_lists/${product}/sector=$(basename $file .csv)"
        mkdir -p $dir
        mv $file $dir/$(basename $file)
    done

    curl -d "Downloaded ${product} list" ntfy.sh/pipeline
}

download qlp 84
download tglc 41


# Rename folders again oops
find . -depth -type d -name 'sector=s*' | while IFS= read -r dir; do
    base=$(basename "$dir")
    num=$(echo "$base" | sed -E 's/sector=s0*//')
    newname=$(printf "sector=%04d" "$num")
    newdir=$(dirname "$dir")/"$newname"

  mv "$dir" "$newdir"
done