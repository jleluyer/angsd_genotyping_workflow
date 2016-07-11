#!/bin/bash

#SBATCH -D ./ 
#SBATCH --job-name="gsnap"
#SBATCH -o log-gsnap
#SBATCH --error="log-gsnap.err"
#SBATCH -c 8
#SBATCH -p ibis2
#SBATCH -A ibis2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=type_your_mail@ulaval.ca
#SBATCH --time=1-00:00
#SBATCH --mem=200000

cd $SLURM_SUBMIT_DIR

# Module prerequis
module load apps/gmap/2016-06-09 

# Global variables
DATAOUTPUT="03_mapped"
DATAINPUT="02_data/demultiplexed"
GENOMEFOLDER="/path1/to/genome/folder"
GENOME="genome_index"

base=__BASE__

    # Align reads
    echo "Aligning $base"

    gsnap --gunzip -t 8 -A sam \
	--dir="$GENOMEFOLDER" -d "$GENOME" \
        -o "$DATAOUTPUT"/"$base".sam \
	"$DATAINPUT"/"$base"_R1.paired.fastq.gz "$DATAINPUT"/"$base"_R2.paired.fastq.gz

    # Create bam file
    echo "Creating bam for $base"

    samtools view -Sb -q 1 -F 4  \
        $DATAOUTPUT/"$base".sam >  $DATAOUTPUT/"$base".bam
	
     echo "Creating sorted bam for $base"
	samtools sort -n "$DATAOUTPUT"/"$base".bam "$DATAOUTPUT"/"$base".sorted
    
    # Clean up
    echo "Removing "$DATAOUTPUT"/"$base".sam"
    echo "Removing "$DATAOUTPUT"/"$base".bam"
