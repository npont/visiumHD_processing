#!/bin/bash

#SBATCH --job-name spatial_mkfastq
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 48 
#SBATCH --mem=64G
#SBATCH -o log/spatial_mkfastq.out
#SBATCH -e log/spatial_mkfastq.err

module load bcl2fastq/2.20.0
module load spaceranger/3.0.1


# This is used to demultiplex the libraries (if several libraries processed in a single run of Ilumina sequencer. Note: libraries are on the Visium slide). It will generate the fastq files from bcl files. It is the first step of Visium HD. The csv file contains info about Lane, Sample and Index, it's what make the demultiplex possible.   
inputdir="/pasteur/zeus/projets/p02/CSD_hpc/data/lab/spatial/EOM_VisiumHD/"
cd ${inputdir}
spaceranger mkfastq --run=240703_VH00505_274_AAFYHNGM5 --id=fastqs --csv=sequencing_sample_sheet.csv
