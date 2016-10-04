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

#move tu pwd
cd $SLURM_SUBMIT_DIR

#set log files
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
NCPU=$1
# Copy script as it was run
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"

cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

# Global variables
INPUT="01_info_files/list_bam"
OUTPUT="-out test_angsd"
NCPU="-P 4"

######## 
# ANGSD variables
#example :angsd -bam list_bam -GL 1 -doGlf 4 -remove_bads 1 -uniqueOnly 1 \
#        -doGeno 4 -doCounts 1 -geno_minDepth 5 -setMinDepth 495 -setMaxDepth 46500 -dumpCounts 2 \
#        -doMaf 2 -minMaf 0.1 -minInd 45 -minMapQ 10 -minQ 10 -doMajorMinor 1 -SNP_pval 1e-6 -hwe_pval 1 -doPost 2 -P 6 \
#        -out geno_catlog_M8N10
# bam
bam="-bam $INPUT"
	rf="-rf [region file]"	 			# Specify multiple regions in a file using the same syntax as -r
	remove_bads="-remove_bads 1"			# Same as the samtools flags -x which removes read with a flag above 255 (not primary, failure and duplicate reads). 0 no , 1 remove (default).
	uniqueOnly="-uniqueOnly 1"			# Remove reads that have multiple best hits. 0 no (default), 1 remove.
	minMapQ="-minMapQ 20"				# Minimum mapQ quality.
	trim="-trim 0"					# Number of bases to remove from both ends of the read.
	only_proper_pairs="-only_proper_pairs 0"	# Include only proper pairs (pairs of read with both mates mapped correctly). 1: include only proper (default), 0: use all reads. If your data is not paired end you have to choose 1.
	C="-C [int] =0"					# Adjust mapQ for excessive mismatches (as SAMtools), supply -ref.
	baq="-baq 0"					# Perform BAQ computation, remember to cite the| BAQ paper for this. 0: No BAQ calcualtion
							# 1:standard BAQ (will downgrade scores).
							# 2:extended BAQ (might also upgrade scores).
							# You will need to supply your reference (-ref) for BAQ options.
	minQ="-minQ 10"		
	checkBamHeaders="-checkBamHeaders 0"		# Exits if the headers are not compatible for all files. 0 no , 1 remove (default). Not performing this check is not advisable
	downSample="-downSample 0"			# Randomly remove reads to downsample your data. 0.25 will on average keep 25% of the reads
	minChunkSize="-minChunkSize 250"		# Minimum number of sites to read in before starting to analyze - larger number will use more RAM

#doGeno
Geno="-doGeno 2"			# 1: write major and minor
					# 2: write the called genotype encoded as -1,0,1,2, -1=not called
					# 4: write the called genotype directly: eg AA,AC etc 
					# 8: write the posterior probability of all possible genotypes
					# 16: write the posterior probability of called genotype
					# 32: write the posterior probabilities of the 3 gentypes as binary
					# -> A combination of the above can be choosen by summing the values, EG write 0,1,2 types with majorminor as -doGeno 3
	
	#postCutoff="-postCutoff 0.333333" 	# (Only genotype to missing if below this threshold)
	#geno_minDepth="-geno_minDepth -1"	# (-1 indicates no cutof)
	#geno_maxDepth="-geno_maxDepth -1"	# (-1 indicates no cutof)
	#geno_minMM="-geno_minMM -1.000000"	# (minimum fraction af major-minor bases)
	#minInd="-minInd 0"			# (only keep sites if you call genotypes from this number of individuals)

					# NB When writing the posterior the -postCutoff is not used
					# NB geno_minDepth requires -doCounts
					#NB geno_maxDepth requires -doCounts

# HWE
HWE="-HWE_pval 0.000000"

# doCounts
Counts="-doCounts 1"			# (Count the number A,C,G,T. All sites, All samples)
	#minQfile="-minQfile file"	 	# file with individual quality score thresholds)
	setMaxDepth="-setMaxDepth 46000"	#(If total depth is larger then site is removed from analysis.
				 		#-1 indicates no filtering)
	setMinDepth="-setMinDepth 65"		#(If total depth is smaller then site is removed from analysis.
				 		#-1 indicates no filtering)
	setMaxDepthInd="-setMaxDepthInd	500"	# (If depth persample is larger then individual is removed from analysis (from site).
				 		# -1 indicates no filtering)
	setMinDepthInd="-setMinDepthInd	5"	# (If depth persample is smaller then individual is removed from analysis (from site).
				 		# -1 indicates no filtering)
	minInd="-minInd	45"			# (Discard site if effective sample size below value.
				 		# 0 indicates no filtering)
	#setMaxDiffObs="-setMaxDiffObs 0"	# (Discard sites where we observe to many different alleles.
				 		# 0 indicates no filtering)
#Filedumping:
#doDepth="-doDepth 0"			# (dump distribution of seqdepth)	.depthSample,.depthGlobal
	#maxDepth="-maxDepth  46000"			# (bin together high depths)
	#doQsDist="-doQsDist 0"			 #(dump distribution of qscores)	.qs
	dumpCounts="-dumpCounts	2"		# 1: total seqdepth for site	.pos.gz
	  					# 2: seqdepth persample		.pos.gz,.counts.gz
	  					# 3: A,C,G,T sum over samples	.pos.gz,.counts.gz
						# 4: A,C,G,T sum every sample	.pos.gz,.counts.gz
	#iCounts="-iCounts 0" 			# (Internal format for dumping binary single chrs,1=simple,2=advanced)
	#qfile="-qfile "				# (Only for -iCounts 2)
	#ffile="-ffile "				 # (Only for -iCounts 2)

# doGL
GL="-GL= 1" 					# 1: SAMtools
						# 2: GATK
						# 3: SOAPsnp
						# 4: SYK
						# 5: phys
	#trim="-trim 0"				# (zero means no trimming)
	#tmpdir="-tmpdir	angsd_tmpdir/"		# (used by SOAPsnp)
	#errors="-errors	(null)"			# (used by SYK)
	minInd="-minInd	45"			# (0 indicates no filtering)

Filedumping:
doGlf="-doGlf 3"				# 1: binary glf (10 log likes)	.glf.gz
						# 2: beagle likelihood file	.beagle.gz
						# 3: binary 3 times likelihood	.glf.gz
						# 4: text version (10 log likes)	.glf.gz

# doMaf
Maf="-doMaf 4"					# 0 (Calculate persite frequencies '.mafs.gz')
						# 1: Frequency (fixed major and minor)
						# 2: Frequency (fixed major unknown minor)
						# 4: Frequency from genotype probabilities
						# 8: AlleleCounts based method (known major minor)
						NB. Filedumping is supressed if value is negative

#Post="-doPost 0"				# 0: (Calculate posterior prob 3xgprob)
						# 1: Using frequency as prior
						# 2: Using uniform prior
						# 3: Using SFS as prior (still in development)
						# 4: Using reference panel as prior (still in development), requires a site file with chr pos major minor af ac an
	#Filters:
	minMaf="-minMaf  -1.000000"		# (Remove sites with MAF below)
	SNP_pval="-SNP_pval 1e-6"		# (Remove sites with a pvalue larger)
	rmTriallelic="-rmTriallelic 0.000000"	# (Remove sites with a pvalue lower)
# Extras:
	#ref="-ref (null)"			# (Filename for fasta reference)
	#anc="-anc (null)"			# (Filename for fasta ancestral)
	#eps="-eps 0.001000"			# [Only used for -doMaf &8]
	#beagleProb="-beagleProb	0"		# (Dump beagle style postprobs)
	#indFame="-indFname (null)" 		# (file containing individual inbreedcoeficients)
						# NB These frequency estimators requires major/minor -doMajorMinor

#doMajorMinor
MajorMinor="-doMajorMinor 0"
						# 1: Infer major and minor from GL
						# 2: Infer major and minor from allele counts
						# 3: use major and minor from a file (requires -sites file.txt)
						# 4: Use reference allele as major (requires -ref)
						# 5: Use ancestral allele as major (requires -anc)
	#rmTrans="-rmTrans: remove transitions 0"
	#skipTriallelic="-skipTriallelic	0"
#########

# launch angsd
angsd  $bam $INPUT $NCPU $OUTPUT \
	$rf $remove_bads $uniqueOnly $minMapQ $minQ $trim $only_proper_pairs $C $baq \
	$checkBamHeaders $downSample $minChunkSize \
	$Geno $postCutoff $geno_minDepth $geno_maxDepth $geno_minMM $minInd \			
	$Glf $HWE \
	$Counts $minQfile $setMaxDepth $setMinDepth $setMaxDepthInd $setMinDepthInd $minInd $setMaxDiffObs \
	$doDepth $maxDepth $doQsDist $dumpCounts $iCounts $qfile $ffil \
	$GL $trim $tmpdir $errors $minInd \
	$Maf $Post $minMaf $SNP_pval $rmTriallelic \
	$ref $anc $eps $beagleProb $indFame \
	$MajorMinor $rmTrans $skipTriallelic '2>&1' '>>' 98_log_files/"$TIMESTAMP"_angsd.log
	

