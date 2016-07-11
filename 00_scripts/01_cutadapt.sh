#!/bin/bash

#SBATCH -D ./ 
#SBATCH --job-name="angsd"
#SBATCH -o log-cutadapt
#SBATCH -c 12
#SBATCH -p ibis2
#SBATCH -A ibis2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=type_your_mail@ulaval.ca
#SBATCH --time=1-00:00
#SBATCH --mem=200000

cd $SLURM_SUBMIT_DIR

# Removing adapters using cutadapt
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
NCPU=$1

# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"

cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Test if user specified a number of CPUs
if [[ -z "$NCPU" ]]
then
    NCPU=1
fi

# Create directory for untrimmed files
mkdir 02_data/trimmed 2>/dev/null

rm 10-log_files/"$TIMESTAMP"_01_cutadapt"${i%.fastq.gz}".log 2> /dev/null

ls -1 02_data/*.f*q.gz |
parallel -j $NCPU cutadapt -a file:01_info_files/adapters.fasta \
        -o 02_raw/trimmed/{/} \
        -e 0.2 \
        -m 50 \
        {} '2>&1' '>>' 98_log_files/"$TIMESTAMP"_01_cutadapt"${i%.fastq.gz}".log
