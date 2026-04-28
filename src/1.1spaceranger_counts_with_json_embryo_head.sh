#!/bin/bash

#SBATCH --job-name cellranger_counts_json_v3
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 50
#SBATCH --mem=128G
#SBATCH --qos=normal
#SBATCH --mail-user=naomie.pont@pasteur.fr
#SBATCH -o log/%x_%J.out
#SBATCH -e log/%x_%J.err

Help()
{
	echo 'sbatch --array=1-2 1.1spaceranger_counts_with_json_embryo_head.sh samples_embryo_head_2.txt'
	echo
	echo 'Adjust the number in --array accordingly to the number of samples'
	echo 
	echo 'This script is used for spaceranger count using the manual alignment of the image to fiducial frame done in Loupe Browser and that provided a json file. It can be used not only because the automatic alignment failed, but also to run spaceranger count with a high resolution image, to downstream be able to apply a segmentation.'
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    Help
    exit 0
fi

module load bcl2fastq/2.20.0
module load spaceranger/3.0.1

# The following will contain the content of each line present in the input text file
full_sample=$(head -n ${SLURM_ARRAY_TASK_ID} $1 | tail -n 1)
# Extract the slide number (A1 or D1) by splitting the string based on "-" separator and keep second field
short_sample=$(echo "$full_sample" | cut -d '-' -f 2)
sample=$(echo Sample_${short_sample})
# Fastq names contain underscore (24_3165p or 24_3165w)
second_name_sample_underscore=$(echo "$full_sample" | cut -d '-' -f 3)
# CytAssist image contains names with hyphen instead of underscore (24-3165p or 24-3165w)
tmp_1=$(echo "$second_name_sample_underscore" | cut -d '_' -f 1)
tmp_2=$(echo "$second_name_sample_underscore" | cut -d '_' -f 2)
second_name_sample_hyphen=$(echo ${tmp_1}-${tmp_2})

datadir="/pasteur/helix/projects/CSD_hpc/data/lab/spatial/embryo_head_VisiumHD/"
refdir="/pasteur/helix/projects/CSD_hpc/data/ref/VisiumHD/refdata-gex-GRCh38-2020-A"
probeset="/pasteur/helix/projects/CSD_hpc/data/ref/VisiumHD/Probeset_v2_human/"
cytaimgroot="${datadir}/images/CAVG10547_2024-11-28_14-48-24_2024-11-28_13-47-46_H1-TZMNJ6D_"
# Naomie output path
output_dir="/pasteur/zeus/projets/p02/Fast_npz/Naomie/visium_HD/visiumHD_outputs/embryo_head/"

# Create the output dir if it does not already exist
mkdir -p ${output_dir}counts/Sample_${short_sample}

spaceranger count --id=${short_sample} \
                    --sample=${second_name_sample_underscore} \
                    --cytaimage=${cytaimgroot}${short_sample}_${second_name_sample_hyphen}.tif \
                    --transcriptome=${refdir} \
                    --probe-set=${probeset}Visium_Human_Transcriptome_Probe_Set_v2.0_GRCh38-2020-A.csv \
                    --fastqs=${datadir}fastq/ShahVisiumHD/outs/fastq_path/AAGCJ32M5/ \
                    --output-dir=${output_dir}counts/${sample} \
                    --create-bam=true \
                    --slide=H1-TZMNJ6D \
                    --area=${short_sample} \
                    --image=${datadir}images/${short_sample}_highres_RGB.tif \
                    --loupe-alignment=${datadir}images/H1-TZMNJ6D-${short_sample}-fiducials-image-registration_highres_RGB.json \
                    --custom-bin-size=10 

#cytaimage: path to the cytAssist image
#probeset: to be downloaded from 10X website 
#image: path to the microscope image i.e. the H&E, that have been converted to TIF format and using high resolution series (from czi, opened on Fiji with Bio-Formats importer, selecting the second series image, then Type>color RGB, and File > Save as > Tif)
#loupe_alignment: json image generated from Loupe Browser when doing the manual alignment of CytAssist image and microscope image 
