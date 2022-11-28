#!/bin/bash

# This needs to be run from Ubuntu terminal (WSL), does not run from bash terminal

pathShred="/mnt/c/Users/tournay/Documents/bbtools/bbmap/shred.sh"
for file in *.fna;
do
  echo "Processing $file file..."
  $pathShred in=$file out=$file-shred.fasta length=500 minlength=500
done
