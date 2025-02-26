#! /usr/bin/env bash
set -e

# SPOC 2m
url_list="./hlsp_lists/spoc_urls.txt"
rm -rf $url_list
for i in $(seq -f "%03g" 1 84); do
    echo "https://tess.mit.edu/public/target_lists/2m/all_targets_S${i}_v1.csv" >> $url_list
done

aria2c -d "./hlsp_lists/spoc" -x 16 -j 16 -i $url_list

for file in ./hlsp_lists/spoc/*; do
    base=$(basename $file _v1.csv)
    dir=./hlsp_lists/spoc/sector=${base#'all_targets_S'}
    
    mkdir -p $dir
    mv $file $dir
done

# SPOC 20s
url_list="./hlsp_lists/spoc_20s_urls.txt"
rm -rf $url_list
for i in $(seq -f "%03g" 27 84); do
    echo "https://tess.mit.edu/public/target_lists/20s/all_targets_20s_S${i}_v1.csv" >> $url_list
done

aria2c -d "./hlsp_lists/spoc20s" -x 16 -j 16 -i $url_list

for file in ./hlsp_lists/spoc20s/*; do
    base=$(basename $file _v1.csv)
    dir=./hlsp_lists/spoc20s/sector=${base#'all_targets_20s_S'}
    
    mkdir -p $dir
    mv $file $dir
done