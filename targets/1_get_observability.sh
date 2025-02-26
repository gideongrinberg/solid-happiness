#!/bin/bash
set -e

rm -rf tmp
mkdir ./tmp
mkdir ./tmp/targets
mkdir ./tmp/pointings/

tail -n +2 targets_ra_dec.csv | split -l 1000 - tmp/targets/part_ 
parallel --bar 'python3 pointer.py {} ./tmp/pointings/{/}' ::: ./tmp/targets/part_*
curl -d "Finished!" ntfy.sh/pipeline