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

# Global variables
INPUT="list_bam"
OUTPUTIND="test_angsd"
#doGeno
Geno="-doGeno 1"			# 1: write major and minor
					# 2: write the called genotype encoded as -1,0,1,2, -1=not called
					# 4: write the called genotype directly: eg AA,AC etc 
					# 8: write the posterior probability of all possible genotypes
					# 16: write the posterior probability of called genotype
					# 32: write the posterior probabilities of the 3 gentypes as binary
					# -> A combination of the above can be choosen by summing the values, EG write 0,1,2 types with majorminor as -doGeno 3
	
postCutoff="-postCutoff=0.333333" 	# (Only genotype to missing if below this threshold)
geno_minDepth="-geno_minDepth=-1"	# (-1 indicates no cutof)
geno_maxDepth="-geno_maxDepth=-1"	# (-1 indicates no cutof)
geno_minMM="-geno_minMM=-1.000000"	# (minimum fraction af major-minor bases)
minInd="-minInd=0"			# (only keep sites if you call genotypes from this number of individuals)

					# NB When writing the posterior the -postCutoff is not used
					# NB geno_minDepth requires -doCounts
					#NB geno_maxDepth requires -doCounts

Glf="-doGlf 1"






# launc angsd
angsd -bam $INPUT 
angsd -bam $INPUT -GL 1 -doGlf 4 -remove_bads 1 -uniqueOnly 1 \
	-doGeno 4 -doCounts 1 -setMinDepth 495 -setMaxDepth 46000 -dumpCounts 2 \
	-doMaf 2 -minMaf 0.1 -minInd 66 -minMapQ 20 -minQ 10 -doMajorMinor 1 -SNP_pval 1e-6 -hwe_pval 1 -doPost 2 -P 12 \
	-out test_pollux_md10_mq20_ma0.1
	
	IN progress
