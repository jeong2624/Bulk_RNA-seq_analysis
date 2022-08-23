#!/bin/bash

set -e # the script to terminate if any command exited with a nonzero exit status.
set -u # Bash scripts not to run any command containing a reference to an unset variable name
set -o pipefail # cover one of the exceptions of set -e: if the last program terminates with a nonzero status, the pipe will not be terminated.

if [ "$#" -lt 2 ] # Are there less than 2 arguments?
then 
	echo "			Description		"
	echo "							  "
	echo "This script is used for quality control check."
	echo "Before using this script, you need to install Fastqc package (conda install -c bioconda fastqc)"
	echo "							  "
	echo "Usage: Bash script for executing quality check. --> ./Fastqc.sh"
	echo "       Input directory where all the neccesary files are saved. --> ./1.Rawdata (SRR391535.fastq.gz or SRR391535_1.fastq.gz / SRR391535_2.fastq.gz)"
	echo "       Output directory where all the results goes. --> ./1.Rawdata/QC_result"
	echo "							  "
	echo "Executable code --> ./Fastqc.sh ./1.Rawdata ./1.Rawdata/QC_result"
    exit 1
fi

read -p "Is the data trimmed? (Yes / No) > " answer1

if [ $answer1 == "No" ]; then
	data_list=$(find $1 -name '*.fastq.gz' -a ! -name '*out*fastq.gz' | sort | uniq)
  echo "Start the quality check using Fastqc!"
	fastqc $data_list -o $2
else
	read -p "What trimming tool did you use? > (Sickle / Trimmomatic) " answer2
	if [ $answer2 == "Sickle" ]; then
		data_list=$(find $1 -name '*sickle_out*fastq.gz' | sort | uniq)
		echo "Start the quality check using Fastqc!"
    fastqc $data_list -o $2
	else
		data_list=$(find $1 -name '*trimmomatic_out*fastq.gz' | sort | uniq)
    echo "Start the quality check using Fastqc!"
		fastqc $data_list -o $2
	fi
fi

echo "The quality check has been completed."
echo "Please confrim!"
