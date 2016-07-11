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
OUTPUTIND="-out test_angsd"
NCPU="-P 4"

######## 
# ANGSD variables

#doGeno
Geno="-doGeno 1"			# 1: write major and minor
					# 2: write the called genotype encoded as -1,0,1,2, -1=not called
					# 4: write the called genotype directly: eg AA,AC etc 
					# 8: write the posterior probability of all possible genotypes
					# 16: write the posterior probability of called genotype
					# 32: write the posterior probabilities of the 3 gentypes as binary
					# -> A combination of the above can be choosen by summing the values, EG write 0,1,2 types with majorminor as -doGeno 3
	
	postCutoff="-postCutoff 0.333333" 	# (Only genotype to missing if below this threshold)
	geno_minDepth="-geno_minDepth -1"	# (-1 indicates no cutof)
	geno_maxDepth="-geno_maxDepth -1"	# (-1 indicates no cutof)
	geno_minMM="-geno_minMM -1.000000"	# (minimum fraction af major-minor bases)
	minInd="-minInd 0"			# (only keep sites if you call genotypes from this number of individuals)

					# NB When writing the posterior the -postCutoff is not used
					# NB geno_minDepth requires -doCounts
					#NB geno_maxDepth requires -doCounts

# HWE
HWE="-HWE_pval 0.000000"

# doCounts
Counts="-doCounts 0"			# (Count the number A,C,G,T. All sites, All samples)
	minQfile="-minQfile	(null)"	 	# file with individual quality score thresholds)
	setMaxDepth="-setMaxDepth	-1"	#(If total depth is larger then site is removed from analysis.
				 		#-1 indicates no filtering)
	setMinDepth="-setMinDepth -1"		#(If total depth is smaller then site is removed from analysis.
				 		#-1 indicates no filtering)
	setMaxDepthInd="-setMaxDepthInd	-1"	# (If depth persample is larger then individual is removed from analysis (from site).
				 		# -1 indicates no filtering)
	setMinDepthInd="-setMinDepthInd	-1"	# (If depth persample is smaller then individual is removed from analysis (from site).
				 		# -1 indicates no filtering)
	minInd="-minInd	0"			# (Discard site if effective sample size below value.
				 		# 0 indicates no filtering)
	setMaxDiffObs="-setMaxDiffObs 0"	# (Discard sites where we observe to many different alleles.
				 		# 0 indicates no filtering)
#Filedumping:
	doDepth="-doDepth 0"			# (dump distribution of seqdepth)	.depthSample,.depthGlobal
	maxDepth="-maxDepth 100"			# (bin together high depths)
	doQsDist="-doQsDist 0"			 #(dump distribution of qscores)	.qs
	dumpCounts="-dumpCounts	0"		# 1: total seqdepth for site	.pos.gz
	  					# 2: seqdepth persample		.pos.gz,.counts.gz
	  					# 3: A,C,G,T sum over samples	.pos.gz,.counts.gz
						# 4: A,C,G,T sum every sample	.pos.gz,.counts.gz
	iCounts="-iCounts 0" 			# (Internal format for dumping binary single chrs,1=simple,2=advanced)
	qfile="-qfile "				# (Only for -iCounts 2)
	ffile="-ffile "				 # (Only for -iCounts 2)

# doGL
GL="-GL= 0" 					# 1: SAMtools
						# 2: GATK
						# 3: SOAPsnp
						# 4: SYK
						# 5: phys
	trim="-trim 0"				# (zero means no trimming)
	tmpdir="-tmpdir	angsd_tmpdir/"		# (used by SOAPsnp)
	errors="-errors	(null)"			# (used by SYK)
	minInd="-minInd	0"			# (0 indicates no filtering)

Filedumping:
	doGlf="-doGlf 0"			# 1: binary glf (10 log likes)	.glf.gz
						# 2: beagle likelihood file	.beagle.gz
						# 3: binary 3 times likelihood	.glf.gz
						# 4: text version (10 log likes)	.glf.gz

# doMaf
Maf="-doMaf 0"					# 0 (Calculate persite frequencies '.mafs.gz')
						# 1: Frequency (fixed major and minor)
						# 2: Frequency (fixed major unknown minor)
						# 4: Frequency from genotype probabilities
						# 8: AlleleCounts based method (known major minor)
						NB. Filedumping is supressed if value is negative

Post="-doPost 0"				# 0: (Calculate posterior prob 3xgprob)
						# 1: Using frequency as prior
						# 2: Using uniform prior
						# 3: Using SFS as prior (still in development)
						# 4: Using reference panel as prior (still in development), requires a site file with chr pos major minor af ac an
	#Filters:
	minMaf="-minMaf  -1.000000"		# (Remove sites with MAF below)
	SNP_pval="-SNP_pval 1.000000"		# (Remove sites with a pvalue larger)
	rmTriallelic="-rmTriallelic 0.000000"	# (Remove sites with a pvalue lower)
# Extras:
	ref="-ref (null)"			# (Filename for fasta reference)
	anc="-anc (null)"			# (Filename for fasta ancestral)
	eps="-eps 0.001000"			# [Only used for -doMaf &8]
	beagleProb="-beagleProb	0"		# (Dump beagle style postprobs)
	indFame="-indFname (null)" 		# (file containing individual inbreedcoeficients)
						# NB These frequency estimators requires major/minor -doMajorMinor

#doMajorMinor
MajorMinor="-doMajorMinor 0"
						# 1: Infer major and minor from GL
						# 2: Infer major and minor from allele counts
						# 3: use major and minor from a file (requires -sites file.txt)
						# 4: Use reference allele as major (requires -ref)
						# 5: Use ancestral allele as major (requires -anc)
	rmTrans="-rmTrans: remove transitions 0"
	skipTriallelic="-skipTriallelic	0"
#########

# launch angsd
angsd -bam $INPUT $NCPU $OUTPUT \
	$Geno $postCutoff $geno_minDepth $geno_maxDepth $geno_minMM $minInd \			
	$Glf $HWE \
	$Counts $minQfile $setMaxDepth $setMinDepth $setMaxDepthInd $setMinDepthInd $minInd $setMaxDiffObs \
	$doDepth $maxDepth $doQsDist $dumpCounts $iCounts $qfile $ffil \
	$GL $trim $tmpdir $errors $minInd \
	$Maf $Post $minMaf $SNP_pval $rmTriallelic \
	$ref $anc $eps $beagleProb $indFame \
	$MajorMinor $rmTrans $skipTriallelic '2>&1' '>>' 98_log_files/"$TIMESTAMP"_angsd.log
	

