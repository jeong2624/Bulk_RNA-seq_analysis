#!/bin/bash

set -e # the script to terminate if any command exited with a nonzero exit status.
set -u # Bash scripts not to run any command containing a reference to an unset variable name
set -o pipefail # cover one of the exceptions of set -e: if the last program terminates with a nonzero status, the pipe will not be terminated.

if [ "$#" -lt 2 ] # Are there less than 2 arguments?
then 
	echo "                      Description               "
	echo "							  "
	echo "This script is used for gene counting by using featurecounts."
	echo "Before using this script, you need to install subread package. (conda install -c bioconda subread)"
	echo "							  "
	echo "Usage: Bash script for executing gene counting. --> ./FeatureCounts.sh"
	echo "       Input directory where all the neccesary files are saved. --> ./2.HISAT (SRR391535.bam)"
	echo "       Output directory where all the results goes. --> ./3.FeatureCounts"
  echo "       Reference directory where all the neccesary files are saved. --> ./0.Reference (Homo_sapiens.GRCh38.dna.primary_assembly.fa, Homo_sapiens.GRCh38.87.gtf)"
	echo "							  "
  echo "Precautions: Separately store paired-end bam files and single-end bam files in the input directory."
  echo "							  "
	echo "Executable code --> ./FeatureCounts.sh ./2.HISAT ./3.FeatureCounts"
    exit 1
fi

bam="*.bam"
GTF="Homo_sapiens.GRCh38.87.gtf"
Reference_dir=$(echo $1 | sed 's/2.HISAT/0.Reference/')

read -p "Is paired-end? (Yes / No) > " answer1
read -p "What is the resulting file name? (ex) Countmatrix > " answer2

if [ $answer1 == "No" ]; then
	featureCounts -T 6 -s 2 -t exon -g gene_id -a $Reference_dir/$GTF -o $2/$answer2.txt $1/$bam
else
	featureCounts -T 6 -p -s 2 -t exon -g gene_id -a $Reference_dir/$GTF -o $2/$answer2.txt $1/$bam
fi
