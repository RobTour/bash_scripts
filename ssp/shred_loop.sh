#!/bin/bash

pathShred="/mnt/c/Users/tournay/Documents/bbtools/bbmap/shred.sh"
pathFiles="1$/*"

for file in $pathFiles
do
  echo "Processing $file file..."
  $pathShred in=$file out=/shredded/$file-shred.fasta length=500 minlength=500
done

## Alternative: execute script from current directory
pathShred="/mnt/c/Users/tournay/Documents/bbtools/bbmap/shred.sh"

for file in *;
do
  echo "Processing $file file..."
  $pathShred in=$file out=/shredded/$file-shred.fasta length=500 minlength=500
done
