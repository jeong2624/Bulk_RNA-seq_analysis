#!/bin/bash

set -e # the script to terminate if any command exited with a nonzero exit status.
set +u # Bash scripts not to run any command containing a reference to an unset variable name
set -o pipefail # cover one of the exceptions of set -e: if the last program terminates with a nonzero status, the pipe will not be terminated.

if [ "$#" -lt 2 ] # Are there less than 2 arguments?
then 
	echo "			   Description                     "
	echo "							  "
	echo "This script is used for genome alignment."
	echo "Before using this script, you need to install Hisat2 and Samtools package."
	echo "							  "
	echo "Usage: Bash script for executing genome alignment --> ./HISAT2.sh"
	echo "       Input directory where all the neccesary files are saved. --> ./1.Rawdata (SRR391535.fastq.gz or SRR391535_1.fastq.gz / SRR391535_2.fastq.gz)"
	echo "       Output directory where all the results goes. --> ./2.HISAT"
  echo "       Reference directory where all the neccesary files are saved. --> ./0.Reference (Homo_sapiens.GRCh38.dna.primary_assembly.fa, Homo_sapiens.GRCh38.87.gtf)"
	echo "							  "
	echo "Executable code --> ./HISAT2.sh ./1.Rawdata ./2.HISAT"
    exit 1
fi

Reference="Homo_sapiens.GRCh38.dna.primary_assembly.fa"
Reference_dir=$(echo $1 | sed 's/1.Rawdata/0.Reference/')
Read1="_1.fastq.gz"
Read2="_2.fastq.gz"
Read=".fastq.gz"

read -p "Do you want to build index? (Yes / No) " answer1
read -p "Is the data trimmed? (Yes / No) > " answer2
read -p "Is paired-end? (Yes / No) " answer3

if [ $answer1 == "Yes" ]; then
	hisat2-build $Reference_dir/$Reference $2/GRCH38
else
	echo "Without indexing build, align genome right away!"
fi

if [ $answer2 == "Yes" ]; then
	read -p "What did you use trimming tool? (Sickle / Trimmomatic) > " answer4
	if [ $answer4 == "Sickle" ]; then
    if [ $answer3 == "No" ]; then
			single_sickle=$(find $1 -name '*sickle_out.fastq.gz' | sort | uniq)
			for infile in $single_sickle
			do
				outfile=$infile
				file_name=$(echo $infile | cut -d '/' -f 3)
        result_name=$(echo $file_name | sed 's/_out.fastq.gz//')
				echo "$file_name file genome alignment start."
				hisat2 -p 14 --rna-strandness RF -x $2/GRCH38 -U ${outfile} 2> $2/$result_name.log | samtools view -@ 8 -Sbo $2/$result_name.bam
        echo "$file_name file genome alignment is complete."
			done
    else
			pair_sickle=$(find $1 -name '*sickle_out_*.fastq.gz' | sort | uniq)
			for infile in $pair_sickle
			do
				outfile=$infile
				file_name=$(echo $infile | cut -d '/' -f  3 | sed 's/_1.fastq.gz//' | sed 's/_2.fastq.gz//' | uniq)
        input_dir=$(echo $outfile | sed 's/_1.fastq.gz//' | sed 's/_2.fastq.gz//' | uniq)
        result_name=$(echo $input_dir | cut -d '/' -f  3 | sed 's/_out//')
				echo "$file_name file genome alignment start."
				hisat2 -p 14 --rna-strandness RF -x $2/GRCH38 -1 ${input_dir}$Read1 -2 ${input_dir}$Read2 2> $2/$result_name.log | samtools view -@ 8 -Sbo $2/$result_name.bam
        echo "$file_name file genome alignment is complete."
			done
    fi		
	else
		if [ $answer3 == "No" ]; then
			single_trimmomatic=$(find $1 -name '*trimmomatic_out.fastq.gz' | sort | uniq)
			for infile in $single_trimmomatic
			do
				outfile=$infile
				file_name=$(echo $infile | cut -d '/' -f 3 | sed 's/.fastq.gz//' | uniq)
        result_name=$(echo $file_name | sed 's/_out.fastq.gz//')
				echo "$file_name file genome alignment start."
				hisat2 -p 14 --rna-strandness RF -x $2/GRCH38 -U ${outfile}_out$Read 2> $2/$result_name.log | samtools view -@ 8 -Sbo $2/$result_name.bam
        echo "$file_name file genome alignment is complete."
			done
		else
			pair_trimmomatic=$(find $1 -name '*trimmomatic_out_*.fastq.gz'| sort | uniq)
			for infile in $pair_trimmomatic
			do
				outfile=$infile
				file_name=$(echo $infile | cut -d '/' -f 3 | sed 's/.fastq.gz//' | uniq)
        input_dir=$(echo $outfile | sed 's/_1.fastq.gz//' | sed 's/_2.fastq.gz//' | uniq)
        result_name=$(echo $input_dir | cut -d '/' -f  3 | sed 's/_out//')
				echo "$file_name file genome alignment start."
				hisat2 -p 14 --rna-strandness RF -x $2/GRCH38 -1 ${input_dir}$Read1 -2 ${input_dir}$Read2 2> $2/$result_name.log | samtools view -@ 8 -Sbo $2/$result_name.bam
        echo "$file_name file genome alignment is complete."
			done
		fi
	fi
 
else
	if [ $answer3 == "No" ]; then
		single_data_list=$(find $1 -name '*.fastq.gz' -a ! -name '*out*fastq.gz' -a ! -name "*_*fastq.gz" | sort | uniq)
		for infile in $single_data_list
		do
			outfile=$infile
			file_name=$(echo $infile | cut -d '/' -f 3 | sed 's/.fastq.gz//' | uniq)
      result_name=$(echo $file_name | sed 's/_out.fastq.gz//')
      echo "$file_name file genome alignment start."
			hisat2 -p 14 --rna-strandness RF -x $2/GRCH38 -U $outfile 2> $2/$result_name.log | samtools view -@ 8 -Sbo $2/$result_name.bam
      echo "$file_name file genome alignment is complete."
		done
	else
		pair_data_list=$(find $1 -name '*_*.fastq.gz' -a ! -name '*out*fastq.gz' | sort | cut -d "_" -f 1 | uniq)
		for infile in $pair_data_list
		do
			outfile=$infile
			file_name=$(echo $infile | cut -d '/' -f 3 | sed 's/.fastq.gz//' | uniq)
      input_dir=$(echo $outfile | sed 's/_1.fastq.gz//' | sed 's/_2.fastq.gz//' | uniq)
      result_name=$(echo $input_dir | cut -d '/' -f  3 | sed 's/_out//')
      echo "$file_name file genome alignment start."
			hisat2 -p 14 --rna-strandness RF -x $2/GRCH38 -1 ${input_dir}$Read1 -2 ${input_dir}$Read2 2> $2/$result_name.log | samtools view -@ 8 -Sbo $2/$result_name.bam
      echo "$file_name file genome alignment is complete."
		done
  fi
fi
