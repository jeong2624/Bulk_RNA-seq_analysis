#!/bin/bash

set -e # the script to terminate if any command exited with a nonzero exit status.
set -u # Bash scripts not to run any command containing a reference to an unset variable name
set -o pipefail # cover one of the exceptions of set -e: if the last program terminates with a nonzero status, the pipe will not be terminated.

if [ "$#" -lt 1 ] # Are there less than 1 arguments?
then 
	echo "                   Description                      "
	echo "							  "
	echo "This script is used for trimming the nucleo acid sequence."
	echo "Before using this script, you need to install Trimming tools (conda install -c bioconda sickle-trim or conda install -c bioconda trimmomatic)"
	echo "							  "
	echo "Usage: Bash script for executing trimming the nucleo acid sequence. --> ./Trimming.sh"
	echo "       Input directory where all the neccesary files are saved. --> ./1.Rawdata (SRR391535.fastq.gz or SRR391535_1.fastq.gz / SRR391535_2.fastq.gz)"
	echo "							  "
	echo "       (Note) Output directory is same as input directory!"
	echo "							  "
	echo "Executable code --> ./Trimming.sh ./1.Rawdata/"
    exit 1
fi

Read=".fastq.gz"
Read1="_1.fastq.gz"
Read2="_2.fastq.gz"
Trim1=".trimmomatic_out"
Trim2=".sickle_out"
read -p "Enter your enviroment name. > " answer1
read -p "Is paired-end? (Yes / No) > " answer2
read -p "What do you use tool? (Sickle / Trimmomatic) > " answer3

single_data_list=$(find $1 -name '*.fastq.gz' -a ! -name '*out*fastq.gz' -a ! -name "*_*fastq.gz" | sort | uniq)
pair_data_list=$(find $1 -name '*_*.fastq.gz' -a ! -name '*out*fastq.gz' | sort | cut -d "_" -f 1 | uniq)

if [ $answer2 == "No" ]; then
		if [ $answer3 == "Trimmomatic" ]; then
			read -p "What do you remove the adapter contents? (TruSeq3 / None) > " answer4
			echo "Start trimming with Trimmomatic!"	
			for infile in $single_data_list
			do
				outfile=$infile
				change_name=$(echo $outfile | sed 's/.fastq.gz/.trimmomatic_out.fastq.gz/')
				if [ $answer4 != "None" ]; then
					trimmomatic SE -threads 4 $outfile $change_name ILLUMINACLIP:$HOME/anaconda3/envs/$answer1/share/trimmomatic-0.39-2/adapters/${answer4}-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
				else
					trimmomatic SE -threads 4 $outfile $change_name LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
				fi
			done

		else
			echo "Start trimming with Sickle!"
			for infile in $single_data_list
                        do
                                outfile=$infile
				change_name=$(echo $outfile | sed 's/.fastq.gz/.sickle_out.fastq.gz/')
				sickle se -f $outfile -t sanger -g -o $change_name
			done
		fi
else
		if [ $answer3 == "Trimmomatic" ]; then
			read -p "What do you remove the adapter contents? (NexteraPE / TruSeq3 / None) > " answer4
			echo "Start trimming with Trimmomatic!"
			for infile in $pair_data_list
			do
				outfile=$infile
				if [ $answer4 != "None" ]; then
					trimmomatic PE -threads 4 $outfile$Read1 $outfile$Read2 $outfile$Trim1$Read1 /dev/null $outfile$Trim1$Read2 /dev/null ILLUMINACLIP:$HOME/anaconda3/envs/$answer1/share/trimmomatic-0.39-2/adapters/${answer4}-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
				else
					trimmomatic PE -threads 4 $outfile$Read1 $outfile$Read2 $outfile$Trim1$Read1 /dev/null $outfile$Trim1$Read2 /dev/null LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
				fi
			done

		else
			echo "Start trimming with Sickle!"
			for infile in $pair_data_list
			do
				outfile=$infile
				sickle pe -f $outfile$Read1 -r $outfile$Read2 -t sanger -g -o $outfile$Trim2$Read1 -p $outfile$Trim2$Read2 -s /dev/null
			done
		fi
fi

echo "Trimming is complete!"
