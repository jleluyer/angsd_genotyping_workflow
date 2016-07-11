#!/bin/bash
#SBATCH -D ./ 
#SBATCH --job-name="gbsx"
#SBATCH -o log-gbsx
#SBATCH --error="log-gbsx.err"
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
LOG_FOLDER="10-log_files"

cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

#Global variables
INPUT="file.fastq.gz"
BARCODES="list_barcodes.txt"
OUTPUT="02_data/demultiplexed"

java -jar GBSX/releases/GBSX_v1.2/GBSX_v1.2.jar --Demultiplexer -f1 $INPUT -i $BARCODES -mb 2 -rad false -gzip true -o $OUTPUT '2>&1' '>>' 98_log_files/"$TIMESTAMP"_gbsx.log
