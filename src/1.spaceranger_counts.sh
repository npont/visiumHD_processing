#!/bin/bash

#SBATCH --job-name cellranger_counts
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 72 
#SBATCH --mem=128G
#SBATCH --mail-user=naomie.pont@pasteur.fr
#SBATCH -o log/%x_%J.out
#SBATCH -e log/%x_%J.err

Help()
{
        echo 'sbatch --array=1-2 1.spaceranger_counts.sh input_samples.txt'
        echo
        echo 'Where input_samples.txt contains sample names per row, such as Sample_A1 Sample_D1'
	echo
	echo 'This script matches the paths for EOM_VisiumHD'
        echo
        echo 'Adjust the number in --array accordingly to the number of samples'
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    Help
    exit 0
fi

module load bcl2fastq/2.20.0
module load spaceranger/3.0.1

# It takes the names of samples written in the file provided as input/argument of this script, where each sample name correspond to a row whose index is the index of the slurm_array_task_id 
sample=$(head -n ${SLURM_ARRAY_TASK_ID} $1 | tail -n 1)
short_sample=${sample/Sample_/}

#EOM_VisiumHD
datadir="/pasteur/zeus/projets/p02/CSD_hpc/data/lab/spatial/EOM_VisiumHD/"
cytaimgroot="${datadir}/CytAssist_img/CAVG10547_2024-06-07_13-22-04_2024-06-07_13-07-20_H1-P77ZJJX_"
output_dir="/pasteur/zeus/projets/p02/Fast_npz/Naomie/Rstudio_spatial/visiumHD_outputs/EOM/"

#Common to EOM_VisiumHD and embryo_head_VisiumHD
refdir="/pasteur/zeus/projets/p02/CSD_hpc/data/ref/VisiumHD/refdata-gex-GRCh38-2020-A"
probeset="/pasteur/zeus/projets/p02/CSD_hpc/data/ref/VisiumHD/Probeset_v2_human/"


# Create output dir if it doesn't already exist
mkdir -p ${output_dir}counts/${sample}

#${sample/Sample_/} is _A1 or _D1 because it takes what is in $sample and removes Sample_ in that so we are left with _A1 or _D1

#sample is Sample_A1 or Sample_D1 -> Need to provide a txt file to this scripts with these characters written as one per row
spaceranger count --id=${sample} \
                    --sample=${sample} \
                    --cytaimage=${cytaimgroot}${short_sample}_sample.tif \
                    --transcriptome=${refdir} \
                    --probe-set=${probeset}Visium_Human_Transcriptome_Probe_Set_v2.0_GRCh38-2020-A.csv \
                    --fastqs=${datadir}fastqs/outs/fastq_path/AAFYHNGM5/ \
                    --output-dir=${output_dir}counts/${sample} \
                    --create-bam=true \
                    --slidefile=${datadir}H1-P77ZJJX.vlf \
                    --slide=H1-P77ZJJX \
                    --area=${short_sample} 


# Note: serial number of Visium HD slides starts with H1 so here I see that we have indeed a visium HD slide (https://www.10xgenomics.com/support/software/space-ranger/latest/analysis/inputs/image-slide-parameters)

# Note: area corresponds to the capture area of the visium slide. There can be 4 if Visium or just 2 if Visium HD. In visium HD they are called A1 and D1. 
