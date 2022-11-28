#!/bin/bash

##################
# Old version
# use RefSeq_dbBuilder.sh
##################


# This script was written as part of the protocols for developing strain specific primers (SSPs). It downloads complete-genome assemblies from a user provided list. The records must be in the correct format for downloading from the NCBI/RefSeq database. One or more files can be added as arguments when executing this script.

# This script works from the command line with one or more arguments passed as files in the tab-separated values (.tsv) format.

# bash RefSeq_dbDownload.sh file1.tsv file2.tsv

#########################################################

echo "What do you want to call this database?"
read DB

# Concatenates user provided files into single file
for var in "$@"
do
  cat $var >> records.txt
done

# Converts records.txt into downloadable format
awk -F $'\t' '{print $20 "/" $1 "_" $16 "_cds_from_genomic.fna.gz"}' records.txt > assemblies.txt

# Downloads and concatenates assembly files
wget -i assemblies.txt
cat *.fna.gz >> db_${DB}.fasta.gz
rm *.fna.gz

# unzip and clean-up
gzip -dk db_${DB}.fasta.gz
mkdir db_${DB}_meta
mv db_${DB}.fasta.gz db_${DB}_meta/
mv records.txt db_${DB}_meta/db_${DB}_records.txt
mv assemblies.txt db_${DB}_meta/db_${DB}_assemblies.txt
# End
