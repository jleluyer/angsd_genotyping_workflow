#!/bin/bash

#SBATCH -D ./ 
#SBATCH --job-name="angsd"
#SBATCH -o log-angsd
#SBATCH --error="log-angsd.err"
#SBATCH -c 12
#SBATCH -p ibis2
#SBATCH -A ibis2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=type_your_mail@ulaval.ca
#SBATCH --time=1-00:00
#SBATCH --mem=200000

cd $SLURM_SUBMIT_DIR


angsd -bam list_bam -GL 1 -doGlf 4 -remove_bads 1 -uniqueOnly 1 \
	-doGeno 4 -doCounts 1 -setMinDepth 495 -setMaxDepth 46000 -dumpCounts 2 \
	-doMaf 2 -minMaf 0.1 -minInd 66 -minMapQ 20 -minQ 10 -doMajorMinor 1 -SNP_pval 1e-6 -hwe_pval 1 -doPost 2 -P 12 \
	-out test_pollux_md10_mq20_ma0.1
