# ANGSD for genotyping and SNPs filtering

This workflow is developped in [Louis Bernatchez' lab](https://www.bio.ulaval.ca/louisbernatchez/presentation.htm).

**WARNING**

The software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

## Installation

```
git clone https://github.com/samtools/htslib.git
git clone https://github.com/ANGSD/angsd.git 
cd htslib;make;cd ../angsd ;make HTSSRC=../htslib
```

## Documentation

### Trimming

```
sbatch 00_scripts/01_cutadapt.sh
```

### Demultiplexing

```
sbatch 00_scripts/02_demultiplexing.sh
```

### Mapping

```
sbatch 00_scripts/03_mapping_gsnap.sh
```

### Genotyping

```
sbatch 00_scripts/04_genotyping.sh
```
**In progress**

## Citation

Korneliussen T. S., Albrechtsen A. and Nielsen R. 2014. ANGSD: Analysis of Next Generation Sequencing Data. *BMC Bioinformatics*. [DOI: 10.1186/s12859-014-0356-4](http://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-014-0356-4)
