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
	echo 'This script matches the paths for embryo_head_VisiumHD'
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
short_sample_1="${sample%-*}" #example: S_24_3165p 
short_sample_2=$(echo "$short_sample_1" | sed -E 's/^S_//') #example: 24_3165p
area="${sample##*-}" #example: A1

#embryo head VisiumHD
datadir="/pasteur/zeus/projets/p02/CSD_hpc/data/lab/spatial/embryo_head_VisiumHD_2/"
cytaimgroot="${datadir}/CytAssist_img/CAVG10547_2024-11-28_14-48-24_2024-11-28_13-47-46_H1-TZMNJ6D_${area}_${short_sample_2}"
output_dir="/pasteur/zeus/projets/p02/Fast_npz/Naomie/visium_HD/visiumHD_outputs/embryo_head/"

#Common to EOM_VisiumHD and embryo_head_VisiumHD
refdir="/pasteur/zeus/projets/p02/CSD_hpc/data/ref/VisiumHD/refdata-gex-GRCh38-2020-A"
probeset="/pasteur/zeus/projets/p02/CSD_hpc/data/ref/VisiumHD/Probeset_v2_human/"



# Create output dir if it doesn't already exist
mkdir -p ${output_dir}counts/Sample_${area}


#sample is Sample_A1 or Sample_D1 -> Need to provide a txt file to this scripts with these characters written as one per row
spaceranger count --id=${short_sample_1} \
                    --sample=${short_sample_1} \
                    --cytaimage=${cytaimgroot}.tif \
                    --transcriptome=${refdir} \
                    --probe-set=${probeset}Visium_Human_Transcriptome_Probe_Set_v2.0_GRCh38-2020-A.csv \
                    --fastqs=${datadir}fastqs/outs/fastq_path/AAGCJ32M5/ \
                    --output-dir=${output_dir}counts/Sample_${area} \
                    --create-bam=true \
                    --slide=H1-TZMNJ6D \
                    --area=${area} \
		    --custom-bin-size=10


# Note: I found the slide serial number in the web summary of the already processed files by Sebastien
# Note: Same for the area so I store the sample names in samples_embryo_head.txt as sample names and capture area
