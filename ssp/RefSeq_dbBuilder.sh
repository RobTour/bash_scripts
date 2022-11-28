#!/bin/bash


# This script was developed as part of the protocols for developing strain specific primers (SSPs). It takes as input a user defined list of strains and creates a single .fasta file of the complete genome assemblies to be used as a local Custom BLAST database in Geneious Prime. The assembly files are obtained from the NCBI/RefSeq database.

# This script works from the command line with the inputs passed as individual arguments, or in a tab-separated values (.tsv) formated file. Arguments can be either by genus (e.g., Pseudomonas) or species (e.g., Pseudomonas putida)
# bash ResSeq_dbBuilder.sh arg1 arg2 arg3
# bash RefSeq_dbBuilder.sh $(cat file.tsv)

#########################################################

# The metadata of bacterial sequences obtained from the NCBI/RefSeq database is stored in the `assembly_summary.txt` document. This script checks whether the file exists in the directory, and if so, that it is less than 30 days old. If neither of those conditions are met, then it download/updates the file. Note: this is a only a list of the NCBI/RefSeq bacterial sequences, and does not contain the actual assemblies.

if [[ ! -f "assembly_summary.txt" ]]
  then
    echo "The assembly database missing, downloading from NCBI/RefSeq now..."
    wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt
    echo "The assembly database downloaded, retrieving files now."
  else
    age=$(($(date +%s)-$(date -r assembly_summary.txt +%s)))
    if [[ $age -gt 2592000 ]]
      then
        echo "The assembly database > 30 days old, updating file from NCBI/RefSeq now..."
        rm assembly_summary.txt
        wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt
        echo "Assembly database updated, retrieving files now."
      else
        echo "OK, retrieving files now."
    fi
fi

# This script filters the assembly_summary.txt file for complete-genome records associated with the user defined genera, and returns the number of `hits` for each. The records are saved in a single document, `records.txt`, and the number of records are reported to the user.

for var in "$@"
do
  awk -v genome="$var" -F $'\t' '$8 ~ genome && $12=="Complete Genome"' assembly_summary.txt > hits.txt
  records=$(awk 'END{print NR}' hits.txt)

  if [[ $records -gt 15 ]]
    then
      echo "$var returned $records records, generating a random subset of 10 records"
      shuf -n 10 hits.txt >> records.txt
    else
      echo "$var returned $records records"
      cat hits.txt >> records.txt
  fi
rm hits.txt
done

total=$(awk 'END{print NR}' records.txt)

echo "$total records returned. Download the assemblies now? y/n"
read CONT

# If the user chooses not to continue, then the program terminates and the results are saved in the file 'results.txt'. If the user chooses to continue, the script prompts the user for a database name, then records in the `records.txt` file are individually downloaded and concatenated into a single `.fasta.gz` file. The file is unzipped, and then intermediate files cleaned-up.

if [[ $CONT =~ [nN] ]]
  then
    echo "OK, stopping. The current list saved in ${var}_results.txt"
    mv records.txt ${var}_results.txt
  else
    echo "What do you want to call this database?"
    read DB

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
fi

# End
