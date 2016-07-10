#!/bin/bash
#$ -N log.gbsx
#$ -M jeremy.le-luyer.1@ulaval.ca
#$ -m beas
#$ -pe smp 1
#$ -l h_vmem=24G
#$ -l h_rt=30:00:00
#$ -cwd
#$ -S /bin/bash




#prerequisities



cd /home/jelel8/test_gbsx/

java -jar GBSX/releases/GBSX_v1.2/GBSX_v1.2.jar --Demultiplexer -f1 JustineP1a-C1.fastq.gz -i barcodelist2.txt -mb 2 -rad false -gzip true -o test_demultiplex/ 
